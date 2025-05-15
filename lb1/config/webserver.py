from flask import Flask, send_file

app = Flask(__name__)


@app.route("/")
def root():
    return send_file("/config/index.html")


if __name__ == "__main__":
    import sys

    port = int(sys.argv[1]) if len(sys.argv) > 1 else 80
    app.run(host="0.0.0.0", port=port)
