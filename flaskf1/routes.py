from flask import Flask, render_template, url_for, flash, redirect
from flaskf1 import app
from flaskf1.dbhandler import DBHandler
from wtforms import BooleanField
from flaskf1.forms import LoginForm, AddSeasonForm, AddRaceForm, AddTeamForm, AddDriverForm, AddPrincipalForm, AddResultForm, DeleteForm, DeleteTwitterForm
from flaskf1.forms import ModifySeasonForm, ModifyRaceForm, ModifyResultForm, ModifyTeamForm, ModifyDriverForm, ModifyPrincipalForm
import pymysql

db = DBHandler()
baseURL = "/f1database"

@app.route(baseURL + "/login", methods=['GET', 'POST'])
def login_page():
  loginform = LoginForm()
  if loginform.validate_on_submit():
    try:
      db.login(loginform.host.data, loginform.username.data, loginform.password.data, loginform.database.data)
      #db.login(loginform.username.data, loginform.password.data)
    except pymysql.err.OperationalError:
      flash('Login failed, try again', 'danger')
    try:
      db.getAllDrivers()
      db.getAllPrincipals()
      db.getAllTeams()
      db.getRaceChoices()
      db.getResultChoices()
      db.getSeasonChoices()
      flash('Logged into account: ' + loginform.username.data, 'success')
      return redirect(url_for('home_page'))
    except:
      flash('Something went wrong, try again?', 'danger')
  return render_template('login.html', form=loginform)

@app.route(baseURL + "/")
@app.route(baseURL + "/home")
def home_page():
  return render_template('home.html')

@app.route(baseURL + "/teams")
def teams_page():
  if db.cnx:
    teams = db.getAllTeams()
    tpsdata = db.getTPSData()
    tpsldata = db.getTPSLData()
    tfsdata, tlsdata = db.getTeamSocialData()

    return render_template('teams.html', tuples=teams, tpsdata=tpsdata, tpsldata=tpsldata, tlsdata=tlsdata, tfsdata=tfsdata)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/teams/<team>")
def teams_info_page(team):
  if db.cnx:
    teams = db.getAllTeams()
    teamInfo = db.getTeamInfo(team)
    dpp = db.getTeamDriverPointsPie(team)
    tca = db.getTeamCompareTwitter(team, teamInfo['followers'], teamInfo['avg_likes'], teamInfo['team_name'], teamInfo['hex_color'])
    return render_template('team_view.html', tuples=teams, current=teamInfo, dppdata=dpp, tcadata=tca)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/drivers")
def drivers_page():
  if db.cnx:
    drivers = db.getAllDrivers()
    dpsdata = db.getDPSData()
    dpsldata = db.getDPSLData()
    dfsdata, dlsdata = db.getDriverSocialData()
    return render_template('drivers.html', tuples=drivers, dpsdata=dpsdata, dpsldata=dpsldata, dlsdata=dlsdata, dfsdata=dfsdata)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/drivers/<driver>")
def drivers_info_page(driver):
  if db.cnx:
    drivers = db.getAllDrivers()
    driverInfo = db.getDriverInfo(driver)
    tca = db.getDriverCompareTwitter(driver, driverInfo['followers'], driverInfo['avg_likes'], driverInfo['fname'] + ' ' + driverInfo['lname'], driverInfo['hex_color'])
    dpp = db.getDriverPercentPie(driver, driverInfo['fname'], driverInfo['lname'], driverInfo['hex_color'], driverInfo['total_score'], driverInfo['team_id'])
    return render_template('driver_view.html', tuples=drivers, current=driverInfo, tcadata=tca, dppdata=dpp)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/add_season", methods=['GET', 'POST'])
def add_season_page():
  if db.cnx:
    seasonForm = AddSeasonForm()
    if seasonForm.validate_on_submit():
      try:
        db.addSeason(seasonForm.season.data)
        flash('Successfully added season', 'info')
      except pymysql.err.IntegrityError:
        flash('Season already exists', 'warning')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('add_files/add_season.html', form=seasonForm)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/add_race", methods=['GET', 'POST'])
def add_race_page():
  if db.cnx:
    raceForm = AddRaceForm()
    raceForm.season.choices = db.getSeasonChoices()

    if raceForm.validate_on_submit():
      try:
        db.addRace(raceForm.track.data, raceForm.date.data, raceForm.season.data)
        flash('Successfully added race', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')
    
    return render_template('add_files/add_race.html', form=raceForm)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/add_result", methods=['GET', 'POST'])
def add_result_page():
  if db.cnx:
    form = AddResultForm()
    form.driver.choices = db.getDriverChoices()
    form.team.choices = db.getTeamChoices()
    form.race.choices = db.getRaceChoices()
    
    if form.validate_on_submit():
      try:
        db.addResult(form.position.data, form.driver.data, form.team.data, form.race.data, form.fastestlap.data)
        flash('Successfully added result', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('add_files/add_result.html', form=form)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/add_team", methods=['GET', 'POST'])
def add_team_page():
  if db.cnx:
    teamForm = AddTeamForm()

    if teamForm.validate_on_submit():
      if (teamForm.username.data == ""):
        try:
          db.addTeam(teamForm.name.data, teamForm.color.data, None)
          flash('Successfully added team', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
      else:
        try:
          db.handleTwitterUsername(teamForm.username.data)
          db.addTeam(teamForm.name.data, teamForm.color.data, teamForm.username.data)
          flash('Successfully added team', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
        except:
          teamForm.username.errors.append('Username does not exist')

    return render_template('add_files/add_team.html', form=teamForm)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/add_driver", methods=['GET', 'POST'])
def add_driver_page():
  if db.cnx:
    driverForm = AddDriverForm()
    driverForm.team.choices = db.getTeamChoices()

    if driverForm.validate_on_submit():

      if (driverForm.username.data == ""):
        try:
          db.addDriver(driverForm.fname.data, driverForm.lname.data, None, driverForm.team.data)
          flash('Successfully added driver', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
      else:
        try:
          db.handleTwitterUsername(driverForm.username.data)
          db.addDriver(driverForm.fname.data, driverForm.lname.data, driverForm.username.data , driverForm.team.data)
          flash('Successfully added driver', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
        except:
          driverForm.username.errors.append('Username does not exist')

    return render_template('add_files/add_driver.html', form=driverForm)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/add_principal", methods=['GET', 'POST'])
def add_principal_page():
  if db.cnx:
    principalForm = AddPrincipalForm()
    principalForm.team.choices = db.getTeamChoices()

    if principalForm.validate_on_submit():

      if (principalForm.username.data == ""):
        try:
          db.addPrincipal(principalForm.fname.data, principalForm.lname.data, None, principalForm.team.data)
          flash('Successfully added principal', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
      else:
        try:
          db.handleTwitterUsername(principalForm.username.data)
          db.addPrincipal(principalForm.fname.data, principalForm.lname.data, principalForm.username.data , principalForm.team.data)
          flash('Successfully added principal', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
        except:
          principalForm.username.errors.append('Username does not exist')
    
    return render_template('add_files/add_principal.html', form=principalForm)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/delete_season", methods=['GET', 'POST'])
def delete_season_page():
  if db.cnx:
    form = DeleteForm()
    form.options.choices = db.getSeasonChoices()

    if form.validate_on_submit():
      try:
        db.deleteSeason(form.options.data)
        form.options.choices = db.getSeasonChoices()
        flash('Successfully deleted season', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')
    
    return render_template('delete_files/delete_season.html', form=form)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/delete_race", methods=['GET', 'POST'])
def delete_race_page():
  if db.cnx:
    form = DeleteForm()
    form.options.choices = db.getRaceChoices()

    if form.validate_on_submit():
      try:
        db.deleteRace(form.options.data)
        form.options.choices = db.getRaceChoices()
        flash('Successfully deleted race', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')
    
    return render_template('delete_files/delete_race.html', form=form)
  else:
    return render_template('connect_database.html')
      
@app.route(baseURL + "/delete_result", methods=['GET', 'POST'])
def delete_result_page():
  if db.cnx:
    form = DeleteForm()
    form.options.choices = db.getResultChoices()

    if form.validate_on_submit():
      try:
        db.deleteResult(form.options.data)
        form.options.choices = db.getResultChoices()
        flash('Successfully deleted result', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')
      
    return render_template('delete_files/delete_result.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/delete_team", methods=['GET', 'POST'])
def delete_team_page():
  if db.cnx:
    form = DeleteForm()
    form.options.choices = db.getTeamChoices()

    if form.validate_on_submit():
      try:
        db.deleteTeam(form.options.data)
        form.options.choices = db.getTeamChoices()
        flash('Successfully deleted team', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('delete_files/delete_team.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/delete_driver", methods=['GET', 'POST'])
def delete_driver_page():
  if db.cnx:
    form = DeleteForm()
    form.options.choices = db.getDriverChoices()

    if form.validate_on_submit():
      try:
        db.deleteDriver(form.options.data)
        form.options.choices = db.getDriverChoices()
        flash('Successfully deleted driver', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('delete_files/delete_driver.html', form=form)
  else:
    return render_template('connect_database.html')


@app.route(baseURL + "/delete_principal", methods=['GET', 'POST'])
def delete_principal_page():
  if db.cnx:
    form = DeleteForm()
    form.options.choices = db.getPrincipalChoices()

    if form.validate_on_submit():
      try:
        db.deletePrincipal(form.options.data)
        form.options.choices = db.getPrincipalChoices()
        flash('Successfully deleted principal', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('delete_files/delete_principal.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/delete_twitter", methods=['GET', 'POST'])
def delete_twitter_page():
  if db.cnx:
    form = DeleteTwitterForm()
    form.options.choices = db.getTwitterDeleteChoices()

    if form.validate_on_submit():
      try:
        db.deleteTwitter(form.options.data)
        form.options.choices = db.getTwitterDeleteChoices()
        flash('Successfully deleted twitter account', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('delete_files/delete_twitter.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/modify_season", methods=['GET', 'POST'])
def modify_season_page():
  if db.cnx:
    form = ModifySeasonForm()
    form.seasons.choices = db.getSeasonChoices()

    if form.validate_on_submit():
      try:
        db.modifySeason(form.seasons.data, form.newval.data)
        form.seasons.choices = db.getSeasonChoices()
        flash('Successfully modified season', 'info')
      except pymysql.err.IntegrityError:
        flash('New season value already exists', 'warning')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')
    
    return render_template('modify_files/modify_season.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/modify_race", methods=['GET', 'POST'])
def modify_race_page():
  if db.cnx:
    form = ModifyRaceForm()
    form.races.choices = db.getRaceChoices()
    form.season.choices = db.getSeasonChoices()

    if form.validate_on_submit():
      try:
        db.modifyRace(form.races.data, form.track.data, form.date.data, form.season.data)
        form.races.choices = db.getRaceChoices()
        flash('Successfully modified race', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('modify_files/modify_race.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/modify_result", methods=['GET', 'POST'])
def modify_result_page():
  if db.cnx:
    form = ModifyResultForm()
    form.result.choices = db.getResultChoices()
    form.driver.choices = db.getDriverChoices()
    form.team.choices = db.getTeamChoices()
    form.race.choices = db.getRaceChoices()

    if form.validate_on_submit():
      try:
        db.modifyResult(form.result.data, form.position.data, form.driver.data, form.team.data, form.race.data, form.fastestlap.data)
        form.result.choices = db.getResultChoices()
        flash('Successfully modified result', 'info')
      except pymysql.Error:
        flash('User does not have permissions to modify', 'warning')

    return render_template('modify_files/modify_result.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/modify_team", methods=['GET', 'POST'])
def modify_team_page():
  if db.cnx:
    form = ModifyTeamForm()
    form.team.choices = db.getTeamChoices()

    if form.validate_on_submit():
      if form.username.data:
        try:
          db.handleTwitterUsername(form.username.data)
          db.modifyTeam(form.team.data, form.name.data, form.color.data, form.username.data)
          form.team.choices = db.getTeamChoices()
          flash('Successfully modified team', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
        except:
          form.username.errors.append('Username does not exist')
      else:
        try:
          db.modifyTeam(form.team.data, form.name.data, form.color.data, None)
          form.team.choices = db.getTeamChoices()
          flash('Successfully modified team', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')

    return render_template('modify_files/modify_team.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/modify_driver", methods=['GET', 'POST'])
def modify_driver_page():
  if db.cnx:
    form = ModifyDriverForm()
    form.driver.choices = db.getDriverChoices()
    form.team.choices = db.getTeamChoices()

    if form.validate_on_submit():
      if form.username.data:
        try:
          db.handleTwitterUsername(form.username.data)
          db.modifyDriver(form.driver.data, form.fname.data, form.lname.data, form.username.data, form.team.data)
          form.driver.choices = db.getDriverChoices()
          flash('Successfully modified driver', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
        except:
          form.username.errors.append('Username does not exist')
      else:
        try:
          db.modifyDriver(form.driver.data, form.fname.data, form.lname.data, None, form.team.data)
          form.driver.choices = db.getDriverChoices()
          flash('Successfully modified driver', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')

    return render_template('modify_files/modify_driver.html', form=form)
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/modify_principal", methods=['GET', 'POST'])
def modify_principal_page():
  if db.cnx:
    form = ModifyPrincipalForm()
    form.principal.choices = db.getPrincipalChoices()
    form.team.choices = db.getTeamChoices()

    if form.validate_on_submit():
      if form.username.data:
        try:
          db.handleTwitterUsername(form.username.data)
          db.modifyPrincipal(form.principal.data, form.fname.data, form.lname.data, form.username.data, form.team.data)
          form.principal.choices = db.getPrincipalChoices()
          flash('Successfully modified principal', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')
        except:
          form.username.errors.append('Username does not exist')
      else:
        try:
          db.modifyPrincipal(form.principal.data, form.fname.data, form.lname.data, None, form.team.data)
          form.principal.choices = db.getPrincipalChoices()
          flash('Successfully modified principal', 'info')
        except pymysql.Error:
          flash('User does not have permissions to modify', 'warning')

    return render_template('modify_files/modify_principal.html', form=form)
  else:
    return render_template('connect_database.html')



@app.route(baseURL + "/season_raw_data")
def season_raw_data_page():
  if db.cnx:
    headers = db.getHeaders('season')
    tuples = db.getTable('season')

    return render_template('raw_data_layout.html', headers=headers, tuples=tuples, title="Seasons Table")
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/race_raw_data")
def race_raw_data_page():
  if db.cnx:
    headers = db.getHeaders('race')
    tuples = db.getTable('race')

    return render_template('raw_data_layout.html', headers=headers, tuples=tuples, title="Races Table")
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/result_raw_data")
def result_raw_data_page():
  if db.cnx:
    headers = db.getHeaders('result')
    tuples = db.getTable('result')

    return render_template('raw_data_layout.html', headers=headers, tuples=tuples, title="Results Table")
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/team_raw_data")
def team_raw_data_page():
  if db.cnx:
    headers = db.getHeaders('team')
    tuples = db.getTable('team')

    return render_template('raw_data_layout.html', headers=headers, tuples=tuples, title="Teams Table")
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/driver_raw_data")
def driver_raw_data_page():
  if db.cnx:
    headers = db.getHeaders('driver')
    tuples = db.getTable('driver')

    return render_template('raw_data_layout.html', headers=headers, tuples=tuples, title="Drivers Table")
  else:
    return render_template('connect_database.html')

@app.route(baseURL + "/principal_raw_data")
def principal_raw_data_page():
  if db.cnx:
    headers = db.getHeaders('principal')
    tuples = db.getTable('principal')

    return render_template('raw_data_layout.html', headers=headers, tuples=tuples, title="Principals Table")
  else:
    return render_template('connect_database.html')
    
@app.route(baseURL + "/twitter_raw_data")
def twitter_raw_data_page():
  if db.cnx:
    headers = db.getHeaders('twitter_info')
    tuples = db.getTable('twitter_info')

    return render_template('raw_data_layout.html', headers=headers, tuples=tuples, title="Twitter Table")
  else:
    return render_template('connect_database.html')