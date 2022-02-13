@debug
Feature: Validate favorite and comment function

  Background: Precondition
    * def isTimeValidator = read('classpath:helpers/TimeValidator.js')
    * url apiUrl
    * configure afterScenario =  function(){ karate.call('Hook.feature'); }


  Scenario: Favorite articles
    # Step 1: Add new article (optimize here - Create a AddArticle.feature)
    * call read('AddArticle.feature')
    # Step 2: Get the favorites count and slug ID for the the article, save it to variables
    * def slugId = response.article.slug
    * def favoritesCount = response.article.favoritesCount
    # Step 3: Make POST request to increase favorites count for the article
    Given path 'articles',slugId,'favorite'
    When method Post
    Then status 200
    # Step 4: Verify response schema
    And match response.article ==
        """
            {
                "id": "#number",
                "slug": "#string",
                "title": "#string",
                "description": "#string",
                "body": "#string",
                "createdAt": "#? isTimeValidator(_)",
                "updatedAt": "#? isTimeValidator(_)",
                "authorId": "#number",
                 "tagList": "#array",
                 "author": {
                    "username": "#string",
                        "bio": "##string",
                        "image": "#string",
                        "following": '#boolean'
                    },
                 "favoritedBy": [
                    {
                        "id": "#number",
                        "email": "#string",
                        "username": "#string",
                        "password": "#string",
                        "image": "#string",
                        "bio": "##string",
                        "demo": '#boolean'
                    }
                 ],
                 "favorited": '#boolean',
                 "favoritesCount": '#number',
            }
        """
    # Step 5: Verify that favorites article incremented by 1
    And match response.article.favoritesCount == favoritesCount + 1
    # Step 6: Get all favorite articles
    Given params {limit: 10, offset: 0, favorited: "#(username)"}
    Given path 'articles'
    When method Get
    Then status 200
    # Step 7: Verify response schema
    And match each response.articles ==
        """
           {
               "slug": "#string",
               "title": "#string",
               "description": "#string",
               "body": "#string",
               "createdAt": "#? isTimeValidator(_)",
               "updatedAt": "#? isTimeValidator(_)",
               "tagList": "#array",
               "author": {
                   "username": "#string",
                   "bio": "##string",
                   "image": "#string",
                   "following": '#boolean'
               },
               "favoritesCount": '#number',
               "favorited": '#boolean'
           }
        """
    # Step 8: Verify that slug ID from Step 2 exist in one of the favorite articles
    And match response.articles[*].slug contains slugId
    # Step 9: Delete the article (optimize here with afterScenario - create a Hook.feature)
#   Given path 'articles',slugId
#   When method Delete
#   Then status 204

  Scenario: Comment articles
    # Step 1: Add new article (optimize here - Create a AddArticle.feature)
    * call read('AddArticle.feature')
    # Step 2: Get the slug ID for the article, save it to variable
    * def slugId = response.article.slug
    * def favoritesCount = response.article.favoritesCount
    # Step 3: Make a GET call to 'comments' end-point to get all comments
    Given path 'articles',slugId,'comments'
    When method Get
    Then status 200
    # Step 4: Verify response schema
    And match response ==
        """
            {
               "comments": "#array"
            }
        """
    # Step 5: Get the count of the comments array length and save to variable
    * def commentsCount = response.comments.length
    # Step 6: Make a POST request to publish a new comment
    * def comment = "Testing comment" + parseInt(Math.random()*10000)
    Given path 'articles',slugId,'comments'
    And request {"comment": {"body": "#(comment)"}}
    When method Post
    Then status 200
    * def commentId = response.comment.id
    # Step 7: Verify response schema that should contain posted comment text
    And match response.comment ==
      """
          {
              "id": "#number",
              "createdAt": "#? isTimeValidator(_)",
              "updatedAt": "#? isTimeValidator(_)",
              "body": "#(comment)",
              "author": {
                  "username": "#string",
                  "bio": "##string",
                  "image": "#string",
                  "following": '#boolean'
              }
          }
      """
    # Step 8: Get the list of all comments for this article one more time
    Given path 'articles',slugId,'comments'
    When method Get
    Then status 200
    # Step 9: Verify number of comments increased by 1 (similar like we did with favorite counts)
    And response.comments.length == commentsCount + 1
    * def commentsCount = response.comments.length
    # Step 10: Make a DELETE request to delete comment
    Given path 'articles',slugId,'comments',commentId
    When method Delete
    Then status 204
    # Step 11: Get all comments again and verify number of comments decreased by 1
    Given path 'articles',slugId,'comments'
    When method Get
    Then status 200
    And response.comments.length == commentsCount - 1
    # Step 12: Delete the article (optimize here with afterScenario - create a Hook.feature)
#   Given path 'articles',slugId
#   When method Delete
#   Then status 204
