from flask import render_template
from app import app #importing the app variable (right) defined in the app package (left)


@app.route('/')
@app.route('/index')
def index():
    user = {'username': 'Bill'}
    posts = [
        {
            'author': {'username': 'John'},
            'body': 'Beautiful day in Paris!'
        },
        {
            'author': {'username': 'Susan'},
            'body': 'Classroom LEDs work!'
        }
    ]
    return render_template('index.html', title='Home', user=user, posts=posts)