from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, PasswordField, BooleanField, SubmitField, IntegerField, DecimalField, DateTimeField
from wtforms.validators import ValidationError, DataRequired, Email, EqualTo, Length
from app.models import User

#This is the form for logging in on the web app.
class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()]) #validators is a list and object, can have more than one
    password = PasswordField('Password', validators=[DataRequired()]) 
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')

class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()]) 
    password2 = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password')]) 
    submit = SubmitField('Register')

    def validate_username(self, username): #custom validators
        user = User.query.filter_by(username=username.data).first()
        if user is not None:
            raise ValidationError('Please use a different username.')

    def validate_email(self, email):
        user = User.query.filter_by(email=email.data).first()
        if user is not None:
            raise ValidationError('Please use a different email address.')

class EditProfileForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    about_me = TextAreaField('About me', validators=[Length(min=0, max=140)])
    submit = SubmitField('Submit')

    def __init__(self, original_username, *args, **kwargs):
        super(EditProfileForm, self).__init__(*args, **kwargs)
        self.original_username = original_username

    def validate_username(self, username):
        if username.data != self.original_username:
            user = User.query.filter_by(username=username.data).first()
            if user is not None:
                raise ValidationError('Please use a different username.')

class Override(FlaskForm):
    color = StringField('Color', render_kw={'placeholder': 'Valid Format is "rrggbb"'}, validators=[DataRequired()])
    brightness = IntegerField('Brightness', render_kw={'placeholder': 'Integer value'}, validators=[DataRequired()])
    mode = StringField('Mode', render_kw={'placeholder': '"solid" or "pulse"'}, validators=[DataRequired()])
    override_duration = IntegerField('Override Duration', render_kw={'placeholder': 'Number of minutes'})
    start_time = StringField('Start Time', render_kw={'placeholder': 'Valid Format is "hh:mm"'}, validators=[DataRequired()])
    submit = SubmitField('Submit')

    def __init__(self, original_username, *args, **kwargs):
        super(Override, self).__init__(*args, **kwargs)
        self.original_username = original_username

class Date(FlaskForm):
    color = StringField('Color', render_kw={'placeholder': 'Valid Format is "rrggbb"'}, validators=[DataRequired()])
    brightness = IntegerField('Brightness', render_kw={'placeholder': 'Integer value'}, validators=[DataRequired()])
    mode = StringField('Mode', render_kw={'placeholder': '"solid" or "pulse"'}, validators=[DataRequired()])
    date = StringField('Date', render_kw={'placeholder': 'Valid Format is "YYYY-MM-DD"'})
    start_time = StringField('Start Time', render_kw={'placeholder': 'Valid Format is "hh:mm"'}, validators=[DataRequired()])
    submit = SubmitField('Submit')

    def __init__(self, original_username, *args, **kwargs):
        super(Date, self).__init__(*args, **kwargs)
        self.original_username = original_username

class DayOfWeek(FlaskForm):
    color = StringField('Color', render_kw={'placeholder': 'Valid Format is "rrggbb"'}, validators=[DataRequired()])
    brightness = IntegerField('Brightness', render_kw={'placeholder': 'Integer value'}, validators=[DataRequired()])
    mode = StringField('Mode', render_kw={'placeholder': '"solid" or "pulse"'}, validators=[DataRequired()])
    day_of_week = StringField('Day of the Week', render_kw={'placeholder': '"monday", "tuesday", "wednesday", "thursday", "friday", "saturday", or "sunday"'})
    start_time = StringField('Start Time', render_kw={'placeholder': 'Valid Format is "hh:mm"'}, validators=[DataRequired()])
    submit = SubmitField('Submit')

    def __init__(self, original_username, *args, **kwargs):
        super(DayOfWeek, self).__init__(*args, **kwargs)
        self.original_username = original_username