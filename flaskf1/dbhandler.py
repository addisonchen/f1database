import pymysql
import random
from flaskf1.tweepycode import TwitterUser


# class uses the connection to handle sql queries
class DBHandler:

  def __init__(self):
    self.cnx = None
    self.tu = TwitterUser()

  # def login(self, host, user, password, database)
  def login(self, host, user, password, db):
    self.cnx = pymysql.connect(host=host, user=user, password=password,
      db=db, autocommit=True, charset='utf8mb4', cursorclass=pymysql.cursors.DictCursor)


  def gen_color(self):
    return ''.join([random.choice('0123456789ABCDEF') for x in range(6)])

  def hasUsername(self, username):
    cursor = self.cnx.cursor()
    query = "SELECT username FROM twitter_info"
    cursor.execute(query)
    received = cursor.fetchall()

    for row in received:
      if row['username'] == username:
        return True
    
    return False

  def refreshUsername(self, username):
    data = self.tu.get_twitter_info(username)
    cursor = self.cnx.cursor()
    query = "CALL refresh_twitter_info(%s, %s, %s)"
    cursor.execute(query, [str(username), data['followers'], data['avg_likes']])
    cursor.close

  def addTwitterUser(self, username):
    data = self.tu.get_twitter_info(username)
    cursor = self.cnx.cursor()
    query = "CALL add_twitter_info(%s, %s, %s)"
    cursor.execute(query, [str(username), data['followers'], data['avg_likes']])
    cursor.close

  def handleTwitterUsername(self, username):
    if self.hasUsername(username):
      self.refreshUsername(username)
    else:
      self.addTwitterUser(username)

  def getAllDrivers(self):
    cursor = self.cnx.cursor()
    query = "CALL all_drivers()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    cleanup = []
    for kv in received:
      cleanup.append({'pk': kv['driver_id'], 'name': kv['fname'] + ' ' + kv['lname']})
    return cleanup

  def getAllTeams(self):
    cursor = self.cnx.cursor()
    query = "CALL all_teams()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    cleanup = []
    for kv in received:
      cleanup.append({'pk': kv['team_id'], 'name': kv['team_name']})
    return cleanup

  def getAllPrincipals(self):
    cursor = self.cnx.cursor()
    query = "CALL all_principals()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    cleanup = []
    for kv in received:
      cleanup.append({'pk': kv['principal_id'], 'name': kv['fname'] + ' ' + kv['lname']})
    return cleanup


  def addSeason(self, season):
    cursor = self.cnx.cursor()
    query = "CALL add_season(%s)"
    cursor.execute(query, season)
    cursor.close

  def addRace(self, track, date, season):
    cursor = self.cnx.cursor()
    query = "CALL add_race(%s, %s, %s)"
    cursor.execute(query, [track, date, season])
    cursor.close

  def addTwitter(self, username, pic, followers, likes):
    cursor = self.cnx.cursor()
    query = "CALL add_twitter_info(%s, %s, %s, %s)"
    cursor.execute(query, [username, pic, followers, likes])
    cursor.close

  def addTeam(self, name, color, username):
    cursor = self.cnx.cursor()
    query = "CALL add_team(%s, %s, %s)"
    cursor.execute(query, [name, color, username])
    cursor.close
  
  def addDriver(self, fname, lname, username, team):
    cursor = self.cnx.cursor()
    query = "CALL add_driver(%s, %s, %s, %s)"
    cursor.execute(query, [fname, lname, username, team])
    cursor.close
  
  def addPrincipal(self, fname, lname, username, team):
    cursor = self.cnx.cursor()
    query = "CALL add_principal(%s, %s, %s, %s)"
    cursor.execute(query, [fname, lname, username, team])
    cursor.close

  def addResult(self, position, driver, team, race, fastestlap):
    cursor = self.cnx.cursor()
    query = "CALL add_result(%s, %s, %s, %s, %s)"
    cursor.execute(query, [position, driver, team, race, fastestlap])
    cursor.close

  def deleteSeason(self, season):
    cursor = self.cnx.cursor()
    query = "CALL delete_season(%s)"
    cursor.execute(query, season)
    cursor.close

  def deleteRace(self, race):
    cursor = self.cnx.cursor()
    query = "CALL delete_race(%s)"
    cursor.execute(query, race)
    cursor.close

  def deleteResult(self, result):
    cursor = self.cnx.cursor()
    query = "CALL delete_result(%s)"
    cursor.execute(query, result)
    cursor.close

  def deleteTeam(self, team):
    cursor = self.cnx.cursor()
    query = "CALL delete_team(%s)"
    cursor.execute(query, team)
    cursor.close
  
  def deleteDriver(self, driver):
    cursor = self.cnx.cursor()
    query = "CALL delete_driver(%s)"
    cursor.execute(query, driver)
    cursor.close

  def deletePrincipal(self, principal):
    cursor = self.cnx.cursor()
    query = "CALL delete_principal(%s)"
    cursor.execute(query, principal)
    cursor.close

  def deleteTwitter(self, twitter):
    cursor = self.cnx.cursor()
    query = "CALL delete_twitter_info(%s)"
    cursor.execute(query, twitter)
    cursor.close


  def modifySeason(self, key, season):
    cursor = self.cnx.cursor()
    query = "CALL modify_season(%s, %s)"
    cursor.execute(query, [key, season])
    cursor.close

  def modifyRace(self, key, track, date, season):
    cursor = self.cnx.cursor()
    query = "CALL modify_race(%s, %s, %s, %s)"
    cursor.execute(query, [key, track, date, season])
    cursor.close

  def modifyResult(self, key, position, driver, team, race, fastestlap):
    cursor = self.cnx.cursor()
    query = "CALL modify_result(%s, %s, %s, %s, %s, %s)"
    cursor.execute(query, [key, position, driver, team, race, fastestlap])
    cursor.close

  def modifyTeam(self, key, name, color, username):
    cursor = self.cnx.cursor()
    query = "CALL modify_team(%s, %s, %s, %s)"
    cursor.execute(query, [key, name, color, username])
    cursor.close

  def modifyDriver(self, key, fname, lname, username, team):
    cursor = self.cnx.cursor()
    query = "CALL modify_driver(%s, %s, %s, %s, %s)"
    cursor.execute(query, [key, fname, lname, username, team])
    cursor.close
  
  def modifyPrincipal(self, key, fname, lname, username, team):
    cursor = self.cnx.cursor()
    query = "CALL modify_principal(%s, %s, %s, %s, %s)"
    cursor.execute(query, [key, fname, lname, username, team])
    cursor.close

  

  def getSeasonChoices(self):
    cursor = self.cnx.cursor()
    query = "SELECT * FROM season"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    pairs = []
    for kv in received:
      pairs.append([kv['season_id'], kv['season_id']])
    return pairs

  def getTeamChoices(self):
    cursor = self.cnx.cursor()
    query = "SELECT team_id, team_name FROM team"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    pairs = []
    for kv in received:
      pairs.append([kv['team_id'], str(kv['team_id']) + ' ' + kv['team_name']])
    return pairs
  
  def getDriverChoices(self):
    cursor = self.cnx.cursor()
    query = "SELECT driver_id, fname, lname FROM driver"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    pairs = []
    for kv in received:
      pairs.append([kv['driver_id'], str(kv['driver_id']) + ' ' + kv['fname'] + ' ' + kv['lname']])
    return pairs

  def getPrincipalChoices(self):
    cursor = self.cnx.cursor()
    query = "SELECT principal_id, fname, lname FROM principal"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    pairs = []
    for kv in received:
      pairs.append([kv['principal_id'], str(kv['principal_id']) + ' ' + kv['fname'] + ' ' + kv['lname']])
    return pairs


  def getRaceChoices(self):
    cursor = self.cnx.cursor()
    query = "SELECT race_id, track, date, season_id FROM race"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    pairs = []
    for kv in received:
      pairs.append([kv['race_id'], str(kv['race_id']) + ' ' + kv['track'] + ', season: ' + str(kv['season_id']) + ', date: ' + str(kv['date'])])
    return pairs

  def getResultChoices(self):
    cursor = self.cnx.cursor()
    query = "CALL get_result_info()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    pairs = []
    for kv in received:
      pairs.append([kv['result_id'], 
        kv['team_name'] + ', ' + kv['lname'] + ', ' + kv['track'] + ', Position: ' + str(kv['position']) + ', Date: ' + str(kv['date'])])
    return pairs
  

  def getTwitterDeleteChoices(self):
    cursor = self.cnx.cursor()
    query = "CALL get_deletable_twitter()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    pairs = []
    for kv in received:
      pairs.append([kv['username'], '@' + kv['username']])
    return pairs


  def getHeaders(self, table):
    cursor = self.cnx.cursor()
    query = f"DESCRIBE {table}"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    headers = []
    for kv in received:
      headers.append(kv['Field'])
    return headers

  def getTable(self, table):
    cursor = self.cnx.cursor()
    query = f"SELECT * FROM {table}"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()
    return received

  def getTPSData(self):
    cursor = self.cnx.cursor()
    query = f"CALL team_point_standings()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()

    data = {'labels': [], 'colors': [], 'points': []}

    for row in received:
      data['labels'].append(row['team_name'])
      data['colors'].append('#' + row['hex_color'])
      if row['s']:
        data['points'].append(int(row['s']))
      else:
        data['points'].append(0)

    data['labels'].append('Average')
    data['colors'].append('#C2C5CC')
    data['points'].append(int(sum(data['points']) / len(data['points'])))
    return data

  def getDPSData(self):
    cursor = self.cnx.cursor()
    query = "CALL driver_point_standings()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()

    data = {'labels': [], 'colors': [], 'points': []}

    for row in received:
      data['labels'].append(row['fname'] + ' ' + row['lname'])
      data['colors'].append('#' + row['hex_color'])
      if row['s']:
        data['points'].append(int(row['s']))
      else:
        data['points'].append(0)

    data['labels'].append('Average')
    data['colors'].append('#C2C5CC')
    data['points'].append(int(sum(data['points']) / len(data['points'])))
    return data
    

  def getTeamSocialData(self):
    cursor = self.cnx.cursor()
    query = "CALL team_follower_standings()"
    cursor.execute(query)
    rf = cursor.fetchall()
    
    tfsdata = {'labels': [], 'colors': [], 'followers': []}
    for row in rf:
      tfsdata['labels'].append(row['team_name'])
      tfsdata['colors'].append('#' + row['hex_color'])
      if row['followers']:
        tfsdata['followers'].append(int(row['followers']))
      else:
        tfsdata['followers'].append(0)
    tfsdata['labels'].append('Average')
    tfsdata['colors'].append('#C2C5CC')
    tfsdata['followers'].append(int(sum(tfsdata['followers']) / len(tfsdata['followers'])))

    query = "CALL team_likes_standings()"
    cursor.execute(query)
    rl = cursor.fetchall()
    
    tlsdata = {'labels': [], 'colors': [], 'likes': []}
    for row in rl:
      tlsdata['labels'].append(row['team_name'])
      tlsdata['colors'].append('#' + row['hex_color'])
      if row['avg_likes']:
        tlsdata['likes'].append(int(row['avg_likes']))
      else:
        tlsdata['likes'].append(0)
    tlsdata['labels'].append('Average')
    tlsdata['colors'].append('#C2C5CC')
    tlsdata['likes'].append(int(sum(tlsdata['likes']) / len(tlsdata['likes'])))

    cursor.close()

    return tfsdata, tlsdata

  def getDriverSocialData(self):
    cursor = self.cnx.cursor()
    query = "CALL driver_follower_standings()"
    cursor.execute(query)
    rf = cursor.fetchall()
    
    dfsdata = {'labels': [], 'colors': [], 'followers': []}
    for row in rf:
      dfsdata['labels'].append(row['fname'] + ' ' + row['lname'])
      dfsdata['colors'].append('#' + row['hex_color'])
      if row['followers']:
        dfsdata['followers'].append(int(row['followers']))
      else:
        dfsdata['followers'].append(0)
    dfsdata['labels'].append('Average')
    dfsdata['colors'].append('#C2C5CC')
    dfsdata['followers'].append(int(sum(dfsdata['followers']) / len(dfsdata['followers'])))

    query = "CALL driver_likes_standings()"
    cursor.execute(query)
    rl = cursor.fetchall()
    
    dlsdata = {'labels': [], 'colors': [], 'likes': []}
    for row in rl:
      dlsdata['labels'].append(row['fname'] + ' ' + row['lname'])
      dlsdata['colors'].append('#' + row['hex_color'])
      if row['avg_likes']:
        dlsdata['likes'].append(int(row['avg_likes']))
      else:
        dlsdata['likes'].append(0)
    dlsdata['labels'].append('Average')
    dlsdata['colors'].append('#C2C5CC')
    dlsdata['likes'].append(int(sum(dlsdata['likes']) / len(dlsdata['likes'])))

    cursor.close()

    return dfsdata, dlsdata
    

  def getRaceNameList(self):
    cursor = self.cnx.cursor()
    query = "SELECT race_id, track, season_id FROM race ORDER BY `date` ASC"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()

    return received

  def getTeamNameList(self):
    cursor = self.cnx.cursor()
    query = "SELECT team_id, team_name, hex_color FROM team"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()

    return received


  def getTPSLData(self):
    races = self.getRaceNameList()
    teams = self.getTeamNameList()
    cursor = self.cnx.cursor()

    datasets = []
    labels = []

    for team in teams:
      sumSoFar = 0
      data = []

      for race in races:
        query = f"SELECT team_race_point_result({team['team_id']}, {race['race_id']})"
        cursor.execute(query)
        received = cursor.fetchall()
        if received[0][f"team_race_point_result({team['team_id']}, {race['race_id']})"]:
          sumSoFar = sumSoFar + int(received[0][f"team_race_point_result({team['team_id']}, {race['race_id']})"])

        data.append(sumSoFar)

      datasets.append({'data': data, 'label': team['team_name'], 'borderColor': '#' + team['hex_color'], 'fill': False})

    for race in races:
      labels.append(race['track'] + ' ' + str(race['season_id']))

    cursor.close()
    return {'labels': labels, 'datasets': datasets}



  def getDriverNameList(self):
    cursor = self.cnx.cursor()
    query = "CALL driver_name_color_list()"
    cursor.execute(query)
    received = cursor.fetchall()
    cursor.close()

    return received

  def getDPSLData(self):
    races = self.getRaceNameList()
    drivers = self.getDriverNameList()
    cursor = self.cnx.cursor()

    datasets = []
    labels = []

    for driver in drivers:
      sumSoFar = 0
      data = []

      for race in races:
        query = f"SELECT driver_race_point_result({driver['driver_id']}, {race['race_id']})"
        cursor.execute(query)
        received = cursor.fetchall()
        if received[0][f"driver_race_point_result({driver['driver_id']}, {race['race_id']})"]:
          sumSoFar = sumSoFar + int(received[0][f"driver_race_point_result({driver['driver_id']}, {race['race_id']})"])

        data.append(sumSoFar)

      datasets.append({'data': data, 'label': driver['fname'][0] + '. ' + driver['lname'], 'borderColor': '#' + driver['hex_color'], 'fill': False})

    for race in races:
      labels.append(race['track'] + ' ' + str(race['season_id']))

    cursor.close()
    return {'labels': labels, 'datasets': datasets}
    

  def getTeamInfo(self, teamID):
    cursor = self.cnx.cursor()
    query = f"SELECT * FROM team WHERE team_id = {teamID}"
    cursor.execute(query)
    received = cursor.fetchall()
    data = received[0]
    if data['username']:
      query = f"SELECT * FROM twitter_info WHERE username = '{data['username']}'"
      cursor.execute(query)
      received = cursor.fetchall()
      data['followers'] = received[0]['followers']
      data['avg_likes'] = received[0]['avg_likes']
    else:
      data['followers'] = 0
      data['avg_likes'] = 0
    
    query = f"SELECT total_team_score({teamID})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"total_team_score({teamID})"]:
      data['total_score'] = received[0][f"total_team_score({teamID})"]
    else:
      data['total_score'] = 0

    query = f"SELECT average_team_score({teamID})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"average_team_score({teamID})"]:
      data['avg_score'] = received[0][f"average_team_score({teamID})"]
    else:
      data['avg_score'] = 0

    query = f"SELECT count_team_wins({teamID})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"count_team_wins({teamID})"]:
      data['wins'] = received[0][f"count_team_wins({teamID})"]
    else:
      data['wins'] = 0

    query = f"SELECT count_team_podiums({teamID})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"count_team_podiums({teamID})"]:
      data['podiums'] = received[0][f"count_team_podiums({teamID})"]
    else:
      data['podiums'] = 0

    cursor.close()
    return data
  
  def getDriverInfo(self, id):
    cursor = self.cnx.cursor()
    query = f"CALL basic_driver_info({id})"
    cursor.execute(query)
    received = cursor.fetchall()

    data = received[0]

    if data['username']:
      query = f"SELECT * FROM twitter_info WHERE username = '{data['username']}'"
      cursor.execute(query)
      received = cursor.fetchall()
      data['followers'] = received[0]['followers']
      data['avg_likes'] = received[0]['avg_likes']
    else:
      data['followers'] = 0
      data['avg_likes'] = 0

    query = f"SELECT total_driver_score({id})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"total_driver_score({id})"]:
      data['total_score'] = received[0][f"total_driver_score({id})"]
    else:
      data['total_score'] = 0

    query = f"SELECT average_driver_score({id})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"average_driver_score({id})"]:
      data['avg_score'] = received[0][f"average_driver_score({id})"]
    else:
      data['avg_score'] = 0

    query = f"SELECT count_driver_wins({id})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"count_driver_wins({id})"]:
      data['wins'] = received[0][f"count_driver_wins({id})"]
    else:
      data['wins'] = 0

    query = f"SELECT count_driver_podiums({id})"
    cursor.execute(query)
    received = cursor.fetchall()
    if received[0][f"count_driver_podiums({id})"]:
      data['podiums'] = received[0][f"count_driver_podiums({id})"]
    else:
      data['podiums'] = 0

    cursor.close()
    return data

  def getTeamDriverPointsPie(self, id):
    cursor = self.cnx.cursor()
    query = f"CALL get_dpp({id})"
    cursor.execute(query)
    received = cursor.fetchall()

    data = {'labels': [], 'colors': [], 'data': []}

    for row in received:
      data['labels'].append(row['fname'] + ' ' + row['lname'])
      data['data'].append(int(row['s']))
      data['colors'].append('#' + self.gen_color())

    cursor.close()
    return data

  def getTeamCompareTwitter(self, id, followers, likes, name, color):
    cursor = self.cnx.cursor()
    query = f"CALL team_avg_twitter()"
    cursor.execute(query)
    received = cursor.fetchall()

    fl = [int(received[0]['f'] / 1000), int(received[0]['l'])]

    datasets = [{'label': name, 'backgroundColor': '#' + color, 'data': [followers / 1000, likes]},
      {'label': 'Average', 'backgroundColor': '#C2C5CC', 'data': fl}]
    
    cursor.close()
    return {'labels': ['Followers (thousand)', 'Average Likes'], 'datasets': datasets}

  def getDriverCompareTwitter(self, id, followers, likes, name, color):
    cursor = self.cnx.cursor()
    query = f"CALL driver_avg_twitter()"
    cursor.execute(query)
    received = cursor.fetchall()

    fl = [int(received[0]['f'] / 1000), int(received[0]['l'])]

    datasets = [{'label': name, 'backgroundColor': '#' + color, 'data': [followers / 1000, likes]},
      {'label': 'Average', 'backgroundColor': '#C2C5CC', 'data': fl}]
    
    cursor.close()
    return {'labels': ['Followers (thousand)', 'Average Likes'], 'datasets': datasets}

  def getDriverPercentPie(self, id, fname, lname, color, driverPoints, teamID):
    cursor = self.cnx.cursor()
    query = f"SELECT total_team_score({teamID})"
    cursor.execute(query)
    received = cursor.fetchall()

    if received[0][f"total_team_score({teamID})"]:
      teamPoints = received[0][f"total_team_score({teamID})"]
    else:
      teamPoints = 0
    
    percent = int((driverPoints / teamPoints) * 100)
    data = [percent, 100-percent]

    cursor.close()
    return {'labels': [fname + ' ' + lname, 'Rest of Team'], 'colors': ['#' + color, '#C2C5CC'], 'data': data}
