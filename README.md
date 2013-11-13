# WebPageTest Reporter System

This is a Ruby app designed to go with WebPageTest that lets you schedule regular test execution and analyse the execution results.

The core concept is that of a test scenario, which is a specific combination of url, browser and connection type (eg Cable, DSL, etc).  Test scenarios are assigned to a 'Scenario Group', which forms a tab in the UI to avoid it being cluttered if there are many test scenarios. 

The app:
 * Allows test scenarios and scenario groups to be created or modified by any user
 * Measures time-to-first byte, time to above-the-fold (either using DOM element or User Timings API) for the page
 * Can display the difference between these (which forms 'client time')
 * Allows variables in test scenario urls (currently just implemented for specific date functions)
 * Can overlay different test scenarios for comparison purposes
 * Can display a list of every object in the page, and a trend graph for each for it's performance over time (especially useful for objects that are downloaded from third parties)

It's particularly designed around the needs of websites where performance needs to be tracked over a long period of time, and around tracking time to above-the-fold rather than page completion.

## Screenshots:

![](screenshots/results_graph.png?raw=true)
![](screenshots/compare.png?raw=true)
![](screenshots/analyse_object.png?raw=true)

## Set-up

It consists of:
 * a MongoDB database to keep track of test scenarios and test results
 * a web-based system to view performance results
 * a cron script to execute tests
 * an admin UI that lets you add/remove test scenarios

As a pre-requisite you will need a private WebPageTest instance configured, this can be on the same or a different machine to the WebPageTest Reporter.

To set up the Reporter:
 * Install MongoDB if it's not already installed, and if it's not on localhost then modify config/database.yml to point to the MongoDB
 * Set web_page_test_url in config/apps.yml to point to the WebPageTest instance
 * Schedule cron to run scripts/run_web_tests.rb every half-an-hour (or at your interval of choice)
 * Run: Create an admin user by running: padrino rake seed 
 * Configure your rails server of choice to point to the app. Alternatively if you are just using it locally, make sure you have Ruby installed and run the following to start the app at http://localhost:9292 :
```
 bundle install
 ./config.ru
```

## Getting started and notes

 * Go to admin (eg http://localhost:9292/admin if you ran config.ru directly) and sign in using the username/password you created when you ran padrino rake seed
 * Select 'Scenario groups' then press the 'New tab to create and name a scenario group then press 'Save' (note that the system currently requires that at least one scenario group exists) 
 * Select 'Scenarios' then press the 'New' tab to create your first scenario. 
 * Once the scenario has finished executing you'll be able to see the results at /summary
 * Once you have created several scenarios you can compare them by clicking the 'Compare' tab
 * The Analyse tab is used to show all the objects that were downloaded in the last run of any given scenario. The Speed Index is a combination of how long the object took to download, and how many other objects were downloading in parallel at the same time (eg a Javascript that blocks anything else downloading simultaneously will have a six times higher Speed Index than a PNG that was downloading at the same time as five other images)
 * By clicking 'trend' to the right of any item in the Analyse tab you can see the download time for that object over time - this is useful for third party items such as ads, though only works if their url stays fixed.  
