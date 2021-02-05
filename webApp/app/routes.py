from app import app #importing the app variable (right) defined in the app package (left)


@app.route('/')
@app.route('/index')
def index():
    return 'Hello, World!'