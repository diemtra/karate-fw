@ignore
Feature: Add a new article

  Background: Define URL
    Given url apiUrl

  Scenario: Create a new article
    * def title = "Articles" + parseInt(Math.random()*10000)
    Given path 'articles'
    And request {"article": {"tagList": [],"title": "#(title)","description": "des","body": "body"}}
    When method Post
    Then status 200
    And match response.article.title == title
