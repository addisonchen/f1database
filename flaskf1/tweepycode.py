#!/usr/bin/env python
# coding: utf-8

# In[1]:

import tweepy


# In[2]:


class TwitterUser:
    def __init__(self, c_API_key = 'FZRX42HL77xkBnB3USXd04mRO', 
                       c_API_skey = 'ubQpDchC82woOZFQRSYF4EDEqvhAfrfZZmG7HCXKlb59LqpmD9',
                       a_token = '1220820088619597824-RDg8kgpGMkdxhMfg349whKMS84ZI6X',
                       a_stoken = 'PCn1TQ5IzfMq7UtvfzFNJt1vYsuKpHXIpzUR7mVQS6Y1y'):
        self.consumer_API_key = c_API_key
        self.consumer_API_secret_key = c_API_skey
        self.access_token = a_token
        self.access_token_secret = a_stoken
    
    def get_twitter_info(self, searched_screen_name):
        auth = tweepy.OAuthHandler(self.consumer_API_key, self.consumer_API_secret_key)
        auth.set_access_token(self.access_token, self.access_token_secret)
        api = tweepy.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)
        
        api = tweepy.API(auth)
        user = api.get_user(screen_name = searched_screen_name)
        
        cursor = tweepy.Cursor(api.user_timeline, screen_name = searched_screen_name, tweet_mode = 'extended')
        counter = 0
        favorite_count = 0
        for tweet in cursor.items(30):
            if (not tweet.retweeted) and ('RT @' not in tweet.full_text) and (counter < 20):
                counter += 1
                favorite_count += tweet.favorite_count
        
        twitter_dic = {}
        
        twitter_dic['avg_likes'] = favorite_count / 20  
        twitter_dic['followers'] = user.followers_count        
        
        return twitter_dic 
        # not sure if a dictionary is the best choice, let me know if it needs to be in another format to be inserted
        # into the SQL table
