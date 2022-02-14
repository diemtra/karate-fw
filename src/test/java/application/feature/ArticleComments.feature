@ignore
Feature: Article comments

  Background: Define URL
    Given url apiUrl

  Scenario: Get article comments
    Given path 'articles',slugId,'comments'
    When method Get
    Then status 200