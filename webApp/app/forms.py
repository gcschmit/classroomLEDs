from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired

#This is the form for logging in on the web app.
class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()]) #validators is a list and object, can have more than one
    password = PasswordField('Password', validators=[DataRequired()]) 
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')