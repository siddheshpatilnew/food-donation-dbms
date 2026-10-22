from datetime import date
from flask import (Flask, render_template, request, redirect,
                   url_for, flash, session)
import mysql.connector
from config import ADMIN_DB, NORMAL_DB

app = Flask(__name__)
app.secret_key = "food-donation-secret"

# Website logins -> MySQL role used for the whole session
USERS = {
    "admin": {"password": "admin123", "role": "admin"},
    "user":  {"password": "user123",  "role": "normal"},
}


def get_db():
    # Admin logs into MySQL as admin_user, normal user as normal_user (DCL in action)
    cfg = NORMAL_DB if session.get("role") == "normal" else ADMIN_DB
    return mysql.connector.connect(**cfg)


def run_write(sql, params, ok_msg=None):
    """Run an INSERT/UPDATE/DELETE. If MySQL refuses (no privilege), show why."""
    db = get_db()
    cur = db.cursor()
    try:
        cur.execute(sql, params)
        db.commit()
        if ok_msg:
            flash(ok_msg, "ok")
    except mysql.connector.Error as e:
        flash("MySQL refused this action for the '" + session.get("role", "") +
              "' user: " + str(e.msg), "err")
    finally:
        cur.close()
        db.close()


@app.context_processor
def inject_user():
    return dict(role=session.get("role"), username=session.get("username"))


@app.before_request
def require_login():
    if request.endpoint in ("login", "static"):
        return None
    if "role" not in session:
        return redirect(url_for("login"))
    return None


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        u = USERS.get(request.form["username"])
        if u and u["password"] == request.form["password"]:
            session["role"] = u["role"]
            session["username"] = request.form["username"]
            return redirect(url_for("home"))
        error = "Wrong username or password"
    return render_template("login.html", error=error)


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/")
def home():
    search = request.args.get("search", "")
    like = "%" + search + "%"
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT f.food_id, f.food_name, f.quantity, f.food_type,
               f.expiry_date, f.status, d.donor_name
        FROM Food f
        JOIN Donor d ON f.donor_id = d.donor_id
        WHERE f.food_name LIKE %s OR d.donor_name LIKE %s OR f.status LIKE %s
    """, (like, like, like))
    foods = cur.fetchall()
    cur.execute("SELECT donor_id, donor_name FROM Donor")
    donors = cur.fetchall()
    cur.close()
    db.close()
    return render_template("foods.html", foods=foods, donors=donors,
                           search=search, today=date.today().isoformat())


@app.route("/add", methods=["POST"])
def add_food():
    run_write("""
        INSERT INTO Food (donor_id, food_name, quantity, food_type, expiry_date)
        VALUES (%s, %s, %s, %s, %s)
    """, (request.form["donor_id"], request.form["food_name"],
          request.form["quantity"], request.form["food_type"],
          request.form["expiry_date"]), "Food added.")
    return redirect(url_for("home"))


@app.route("/edit/<int:food_id>", methods=["GET", "POST"])
def edit_food(food_id):
    if request.method == "POST":
        run_write("""
            UPDATE Food
            SET food_name=%s, quantity=%s, food_type=%s,
                expiry_date=%s, status=%s
            WHERE food_id=%s
        """, (request.form["food_name"], request.form["quantity"],
              request.form["food_type"], request.form["expiry_date"],
              request.form["status"], food_id), "Food updated.")
        return redirect(url_for("home"))
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM Food WHERE food_id=%s", (food_id,))
    food = cur.fetchone()
    cur.close()
    db.close()
    return render_template("edit.html", food=food, today=date.today().isoformat())


@app.route("/delete/<int:food_id>", methods=["POST"])
def delete_food(food_id):
    run_write("DELETE FROM Food WHERE food_id=%s", (food_id,), "Food deleted.")
    return redirect(url_for("home"))


@app.route("/deliveries")
def deliveries():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("""
        SELECT dl.delivery_id, f.food_name, n.ngo_name, b.beneficiary_name,
               dl.delivery_date, dl.quantity, dl.delivery_status
        FROM Delivery dl
        JOIN Food f ON dl.food_id = f.food_id
        JOIN NGO n ON dl.ngo_id = n.ngo_id
        JOIN Beneficiary b ON dl.beneficiary_id = b.beneficiary_id
        ORDER BY dl.delivery_id DESC
    """)
    rows = cur.fetchall()
    cur.execute("SELECT food_id, food_name, quantity FROM Food WHERE quantity > 0")
    foods = cur.fetchall()
    cur.execute("SELECT ngo_id, ngo_name FROM NGO")
    ngos = cur.fetchall()
    cur.execute("SELECT beneficiary_id, beneficiary_name FROM Beneficiary")
    bens = cur.fetchall()
    cur.close()
    db.close()
    return render_template("deliveries.html", rows=rows, foods=foods,
                           ngos=ngos, bens=bens)


@app.route("/deliveries/add", methods=["POST"])
def add_delivery():
    db = get_db()
    cur = db.cursor()
    try:
        cur.callproc("AddDelivery", (request.form["food_id"], request.form["ngo_id"],
                                     request.form["beneficiary_id"], request.form["quantity"]))
        db.commit()
        flash("Delivery created. Food stock was reduced automatically by the trigger.", "ok")
    except mysql.connector.Error as e:
        flash("Error: " + str(e.msg), "err")
    finally:
        cur.close()
        db.close()
    return redirect(url_for("deliveries"))


@app.route("/deliveries/delivered/<int:delivery_id>", methods=["POST"])
def mark_delivered(delivery_id):
    run_write("UPDATE Delivery SET delivery_status='Delivered' WHERE delivery_id=%s",
              (delivery_id,), "Delivery marked as delivered.")
    return redirect(url_for("deliveries"))


if __name__ == "__main__":
    app.run(debug=True, port=5001)
