# boggle-api

Author: Lim Mingyi

Date: 04/08/2020

This project is part of the assignment from Saleswhale as part of the recruitment process.
It contains the boggle api which can be used to serve a boggle
game for players. This readme will describe how to setup and run this 
basic api. 

Documentation of my thought process can be found below

## Setup
###Requirements
Ruby version: 2.6

bundle (install using gem install bundle)

### Building the Project
Start by installing dependencies using
> <code> bundle install </code>
Then, create the database by running
> <code> rails db:migrate </code>
Running rspecs (unit tests):
> <code> bundle exec rspec spec

### Initialising the Server
On a terminal, start by running
> <code> rails server  </code>
This should start the server on http://localhost:3000

## API Use (from problem statement)
### Create the game

- Endpoint

```
POST /games
```

- Parameters:
  + `duration` (required): the time (in seconds) that specifies the duration of
    the game
  + `random` (required): if `true`, then the game will be generated with random
    board.  Otherwise, it will be generated based on input.
  + `board` (optional): if `random` is not true, this will be used as the board
    for new game. If this is not present, new game will get the default board
    from `test_board.txt`

- Response:
  + Success (status 201 Created)

```json
{
  "id": 1,
  "token": "9dda26ec7e476fb337cb158e7d31ac6c",
  "duration": 12345,
  "board": "A, C, E, D, L, U, G, *, E, *, H, T, G, A, F, K"
}
```

### Play the game

- Endpoint

```
PUT /games/:id
```

- Parameters:
  + `id` (required): The ID of the game
  + `token` (required): The token for authenticating the game
  + `word` (required): The word that can be used to play the game

- Response:
  + Success (status 200 OK)

```json
{
  "id": 1,
  "token": "9dda26ec7e476fb337cb158e7d31ac6c",
  "duration": 12345,
  "board": "A, C, E, D, L, U, G, *, E, *, H, T, G, A, F, K",
  "time_left": 10000,
  "points": 10
}
```

### Show the game

- Endpoint

```
GET /games/:id
```

- Parameters:
  + `id` (required): The ID of the game

- Response:
  + Success (status 200 OK)

```json
{
  "id": 1,
  "token": "9dda26ec7e476fb337cb158e7d31ac6c",
  "duration": 12345,
  "board": "A, C, E, D, L, U, G, *, E, *, H, T, G, A, F, K",
  "time_left": 10000,
  "points": 10
}
```
## Discussion
I want to start by saying that while my experience with the rails
framework (but not ruby) is limited, I learnt a lot during this project, so I would
like to thank SalesWhale for the opportunity to work on this.

In this section I would like to document and explain my thoughts behind certain
design decisions or choice methods in key areas of the code.

I will describe my thought process behind the following major components
1. Design Patterns
2. Finding entries in board (search algorithm)
3. Game Schema

### Design Patterns
Given the MVC framework, separation of responsibility is important between
the controllers and the Model. 
The Model should handle data related operations on the model object
while controllers should serve the correct data to the model and render views.

#### GamesCreator
However, given the complex nature of the model initialisation, I decided to create
a new class called <code> GamesCreator </code>.

GamesCreator handles the following:
1. Input Validation
2. Object construction for fixed and random attributes
3. Construction of the game model

By designating these tasks to the GamesCreator, we reduce the bulk in the
corresponding controller which gives us more readable code, while delegating
the responsibility of object creation logic to another logical unit (or class).

Should we decide to change how the game object is initialised in future, we can 
do so easily by just editing the GamesCreator class and methods.
The model is built and returned to the controller. More importantly, only the 
controller calls save to publish any changes to the database if needed. Once again,
separation of responsibility.

#### GamesManager

Once again, we have an issue with the logic of validation and search. While it 
shouldn't go into the controller, it doesn't directly deal with the model itself. 
Thus, I decided to write a separate class to handle searching logic and model interaction.
GamesManager contains all the GameError classes which allows us to specify custom errors
in a readable form. This also allows us to group and consolidate errors which can be 
rescued by the controller.

By the use of these 2 service classes, we can keep the controller thin and the model
(and services) fat, while achieving separation of components.

### Search Algorithm: finding entries in the board

For this section, I considered several approaches, each with tradeoffs:
1. Naive search: find every single substring on the board and check if
a word exists in the board. O(4^n) runtime, O(1) space, where n is length of a word
2. Backtracking Depth First search: Find all the starting points of the word, conduct depth-first search 
on all starting points to see if the word exists. O(4^n) runtime, O(n) space
3. Word Hashing: upon initialisation of the board, we 
iterate through the dictionary and check if each word exists on the board. If it does,
we save the word in a set. Future lookups just need to query the set. Lookup: O(1) time complexity
Initialisastion: O(D) runtime where D is the chars in the dictionary. O(D) space complexity

While both 2 and 3 were viable solutions here, I decided to go with algorithm 2 for
the following reason:
1. Given the small size of the board, the runtime of the algorithm is not as much of 
a concern. Given the random nature of the board and the rarity of words with a the average time complexity is 
unlikely to be near the worst-case, if at all.
2. The storage of large amounts of words, while would provide a better worst-case runtime, might prove 
to be a bad tradeoff here as the database entries keep coming in. The response time of this search
pales in comparison to the latency from the API over a network connection and is thus not worth
the extra storage.

Thus, i decided to go with the DFS method which is easy to follow and provides decent average time
complexity and space complexity.

### Games Schema
The game schema is almost identically as described by the problem statement, with slight changes
1. The game retains a set of all visited words. This is important for validation
2. The game retains a alternate representation of the board in the form of a char_map.
This represents a slight tradeoff between space complexity for speed in searching.

### Conclusion
I definitely enjoyed building this, and if anything it was a great learning experience.
I would still like to learn more about design patterns in Rails if given the chance - as well
as to validate some of the assumptions I had about the MVC architecture. While my understanding
of the topic might be rudimentary for now, I will definitely look to learn more about it in 
my own time, or better yet, given the change to do so in the Backend Engineering team.

I hope this gives you a glimpse into my thought process, and that you can let me know
what feedback you have for me after this assignment!

Mingyi



 


