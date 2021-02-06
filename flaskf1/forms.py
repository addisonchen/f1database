from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, IntegerField, DateField, FileField, SelectField, BooleanField
from wtforms.validators import DataRequired, Length, Regexp

class LoginForm(FlaskForm):
  host = StringField('Host', validators=[DataRequired()])
  database = StringField('Database', validators=[DataRequired()])
  username = StringField('Username', validators=[DataRequired()])
  password = PasswordField('Password ("password" for guest user)')
  submit = SubmitField('Connect')

class AddSeasonForm(FlaskForm):
  season = IntegerField('Season', validators=[DataRequired()])
  submit = SubmitField('Add')

class AddRaceForm(FlaskForm):
  track = StringField('Circuit', validators=[DataRequired()])
  date = DateField('Date', validators=[DataRequired()])
  season = SelectField('Season', coerce=int)
  submit = SubmitField('Add')

class AddTwitterForm(FlaskForm):
  username = StringField('Username', validators=[DataRequired(), Length(max=15)])
  pic = FileField('Profile Picture', validators=[DataRequired()])
  followers = IntegerField('Followers', validators=[DataRequired()])
  likes = IntegerField('Likes', validators=[DataRequired()])
  submit = SubmitField('Add')

class AddTeamForm(FlaskForm):
  name = StringField('Team Name', validators=[DataRequired()])
  color = StringField('Hex Color', validators=[DataRequired(), Regexp(regex=r'^[A-Fa-f0-9]{6}$', message="Must be a valid hex color (no '#')")])
  username = StringField('Twitter Username', validators=[Length(max=15)])
  submit = SubmitField('Add')


class AddDriverForm(FlaskForm):
  fname = StringField('First Name', validators=[DataRequired()])
  lname = StringField('Last Name', validators=[DataRequired()])
  username = StringField('Twitter Username', validators=[Length(max=15)])
  team = SelectField('Team', coerce=int)
  submit = SubmitField('Add')


class AddPrincipalForm(FlaskForm):
  fname = StringField('First Name', validators=[DataRequired()])
  lname = StringField('Last Name', validators=[DataRequired()])
  username = StringField('Twitter Username', validators=[Length(max=15)])
  team = SelectField('Team', coerce=int)
  submit = SubmitField('Add')

class AddResultForm(FlaskForm):
  position = SelectField('Position', coerce=int, choices=[(i,i) for i in range(1, 27)])
  driver = SelectField('Driver', coerce=int)
  team = SelectField('Team', coerce=int)
  race = SelectField('Race', coerce=int)
  fastestlap = BooleanField('Fastest Lap')
  submit = SubmitField('Add')

class DeleteForm(FlaskForm):
  options = SelectField('Options', coerce=int)
  submit = SubmitField('Delete')

class DeleteTwitterForm(FlaskForm):
  options = SelectField('Options', coerce=str)
  submit = SubmitField('Delete')


class ModifySeasonForm(FlaskForm):
  seasons = SelectField('Season to change', coerce=int)
  newval = IntegerField('New value', validators=[DataRequired()])
  submit = SubmitField('Update')

class ModifyRaceForm(FlaskForm):
  races = SelectField('Race to change', coerce=int)
  track = StringField('Circuit', validators=[DataRequired()])
  date = DateField('Date', validators=[DataRequired()])
  season = SelectField('Season', coerce=int)
  submit = SubmitField('Update')

class ModifyResultForm(FlaskForm):
  result = SelectField('Result to change', coerce=int)
  position = SelectField('Position', coerce=int, choices=[(i,i) for i in range(1, 27)])
  driver = SelectField('Driver', coerce=int)
  team = SelectField('Team', coerce=int)
  race = SelectField('Race', coerce=int)
  fastestlap = BooleanField('Fastest Lap')
  submit = SubmitField('Update')

class ModifyTeamForm(FlaskForm):
  team = SelectField('Team to change', coerce=int)
  name = StringField('Team Name', validators=[DataRequired()])
  color = StringField('Hex Color', validators=[DataRequired(), Regexp(regex=r'^[A-Fa-f0-9]{6}$', message="Must be a valid hex color (no '#')")])
  username = StringField('Twitter Username', validators=[Length(max=15)])
  submit = SubmitField('Add')



class ModifyDriverForm(FlaskForm):
  driver = SelectField('Driver to change', coerce=int)
  fname = StringField('First Name', validators=[DataRequired()])
  lname = StringField('Last Name', validators=[DataRequired()])
  username = StringField('Twitter Username', validators=[Length(max=15)])
  team = SelectField('Team', coerce=int)
  submit = SubmitField('Add')


class ModifyPrincipalForm(FlaskForm):
  principal = SelectField('Principal to change', coerce=int)
  fname = StringField('First Name', validators=[DataRequired()])
  lname = StringField('Last Name', validators=[DataRequired()])
  username = StringField('Twitter Username', validators=[Length(max=15)])
  team = SelectField('Team', coerce=int)
  submit = SubmitField('Add')