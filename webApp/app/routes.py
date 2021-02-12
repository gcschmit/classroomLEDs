from flask import render_template, flash, redirect, url_for
from app import app #importing the app variable (right) defined in the app package (left)
from app.forms import LoginForm

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

@app.route('/login', methods=['GET', 'POST'])
def login(): #Figure out which 
    form = LoginForm()
    if form.validate_on_submit():
        flash('Login requested for user {}, remember_me={}'.format(
            form.username.data, form.remember_me.data))
        return redirect(url_for('index'))
    return render_template('login.html', title='Sign In', form=form)