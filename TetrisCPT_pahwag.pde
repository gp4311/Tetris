// =============================================================================================================== //
// ==================================================  GLOBAL  =================================================== //
// =============================================================================================================== //

PlayField playField;
Button play, instructions, leaderboard, backToMenu, submit, exit, pause;
Letter firstInitial, secondInitial, thirdInitial;
HighScore firstPlace, secondPlace, thirdPlace;

String [] alphabet = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};

ArrayList <Tetromino> tetrominos;
ArrayList <Block> allBlocks;

color bgColor;
String gameState, playerIns;
int timer, linesCleared, level, points, speed;
boolean stationary, playing;


// =============================================================================================================== //
// ==================================================  SETUP  ==================================================== //
// =============================================================================================================== //

void setup()
{
  size(750, 800);
  ellipseMode(CORNER);

  playField = new PlayField();

  //Initialize the tetronmino ArrayList
  tetrominos = new ArrayList <Tetromino>();

  //Initialize the allBlocks ArrayList
  allBlocks = new ArrayList <Block>();

  //Initialize the buttons
  play = new Button (150, 420, 100, 30, color (2, 28, 64), color (2, 28, 64), 32, color (255, 255, 255), "PLAY");
  instructions = new Button (150, 480, 250, 30, color (2, 28, 64), color (2, 28, 64), 32, color (255, 255, 255), "INSTRUCTIONS");
  leaderboard = new Button (150, 540, 250, 30, color (2, 28, 64), color (2, 28, 64), 32, color (255, 255, 255), "LEADERBOARD");

  backToMenu = new Button (637.5, 12, 100, 30, color (255, 255, 255), color (255, 255, 255), 32, color (0, 0, 0), "BACK");

  exit = new Button (637.5, 12, 87, 30, color (255, 255, 255), color (255, 255, 255), 32, color (0, 0, 0), "EXIT");
  pause = new Button (637.5, 50, 87, 30, color (255, 255, 255), color (255, 255, 255), 23, color (0, 0, 0), "PAUSE");

  submit = new Button (318.75, 560, 130, 30, color (255, 255, 255), color (255, 255, 255), 32, color (0, 0, 0), "SUBMIT");

  //Initialize leaderboard's highest scores and corresponding initials
  firstPlace = new HighScore();
  secondPlace = new HighScore();
  thirdPlace = new HighScore();

  firstPlace.score = 16000;
  secondPlace.score = 10000;
  thirdPlace.score = 5000;

  firstPlace.playerInitials = "AAA";
  secondPlace.playerInitials = "BBB";
  thirdPlace.playerInitials = "CCC";

  //Initialize letter spinners
  firstInitial = new Letter (70, 240, 200, 250);
  secondInitial = new Letter (281.75, 240, 200, 250);
  thirdInitial = new Letter (493.5, 240, 200, 250);

  //Initialize background color
  bgColor = color (2, 28, 64);

  //Initialize starting game state
  gameState = "Menu";
}

// =============================================================================================================== //
// ==================================================  DRAW  ===================================================== //
// =============================================================================================================== //

void draw()
{
  //Increment timer (timer is used for movement of the Tetromino)
  if ((gameState == "In Game" || gameState == "Game Over") && playing == true)
  {
    timer ++;
  }

  // ===========================================  MOVE STUFF  ==================================================== //

  if (gameState == "In Game" && playing == true)
  {
    //Move the current Tetromino
    for (int i = 0; i < tetrominos.size(); i ++)
    {
      Tetromino a = tetrominos.get(i);

      if (timer % speed == 0 && stationary == false)
      {
        a.moveTetromino();
      }
    }
  }

  // ============================================  COLLISION  ==================================================== //

  if (gameState == "In Game" && playing == true)
  {
    //Check for Tetromino's collision with the walls of the playField
    for (int i = 0; i < tetrominos.size(); i ++)
    {
      Tetromino a = tetrominos.get(i);
      a.collisionWithWalls();
    }

    //Check for Tetromino's collision with the bottom of the playField or other blocks
    for (int i = 0; i < tetrominos.size(); i ++)
    {
      Tetromino a = tetrominos.get(i);

      if (a.collisionWithBottom() == true || checkCollisionTetrominoBlocks("bottom", a.x1, a.y1, a.x2, a.y2, a.x3, a.y3, a.x4, a.y4, a.w, a.h) == true)
      {
        stationary = true;

        //Timer allows the user to shift the Tetromino for a brief time after it has collided
        if (timer % 100 == 0)
        {
          //If a collision with the bottom of the screen occurs, blocks will be generated in the positions of the supposed Tetromino shape
          Block b = new Block(a.x1, a.y1, a.w, a.h, a.tetrominoColor);
          allBlocks.add(b);

          Block c = new Block(a.x2, a.y2, a.w, a.h, a.tetrominoColor);
          allBlocks.add(c);

          Block d = new Block(a.x3, a.y3, a.w, a.h, a.tetrominoColor);
          allBlocks.add(d);

          Block e = new Block(a.x4, a.y4, a.w, a.h, a.tetrominoColor);
          allBlocks.add(e);

          //Current Tetromino is removed
          tetrominos.remove(i);

          stationary = false;
        }

        //Each row of the playfield is checked for 10 blocks
        checkingRows();
      } else if (a.collisionWithBottom() == false || checkCollisionTetrominoBlocks("bottom", a.x1, a.y1, a.x2, a.y2, a.x3, a.y3, a.x4, a.y4, a.w, a.h) == false)
      {
        stationary = false;
      }
    }

    //Check for Block's collision with the top of the playField
    for (int i = 0; i < allBlocks.size(); i ++)
    {
      Block b = allBlocks.get(i);

      if (b.y == playField.y)
      {
        tetrominos.clear();
        allBlocks.clear();

        gameState = "Game Over";
      }
    }
  }

  // ===========================================  DRAW STUFF  ==================================================== //

  background(bgColor);

  if (gameState == "Menu")
  {
    drawLogo();

    play.drawButton();
    instructions.drawButton();
    leaderboard.drawButton();
  } else if (gameState == "Leaderboard")
  {
    backToMenu.drawButton();
    drawLeaderboard();
  } else if (gameState == "Instructions")
  {
    writeInstructions(); 
    backToMenu.drawButton();
  } else if (gameState == "Enter Initials")
  {
    textSize(32);
    fill(255);
    text ("You placed on the leaderboard!", 125, 50);

    textSize(20);
    text ("Enter your initials by clicking the arrows", 160, 115);
    text ("above and below each letter. Then hit the submit button.", 105, 145);

    submit.drawButton();
    firstInitial.drawLetter();
    secondInitial.drawLetter();
    thirdInitial.drawLetter();
  } else if (gameState == "In Game")
  {
    playField.drawPlayField();

    exit.drawButton();
    pause.drawButton();

    //If previous tetromino was removed and the timer is appropriate, a new Tetromino is generated
    if (tetrominos.size() == 0 && playing == true)
    {
      Tetromino t = new Tetromino();
      tetrominos.add(t);
    }

    for (int i = 0; i < tetrominos.size(); i ++)
    {
      Tetromino a = tetrominos.get(i);
      a.drawTetromino();
    }

    for (int i = 0; i < allBlocks.size(); i ++)
    {
      Block b = allBlocks.get(i);
      b.drawBlock();
    }

    fill(255);
    textSize(25);

    text("Lines Cleared: " + linesCleared, 450, 300);
    text("Score: " + points, 450, 370);
  } else if (gameState == "Game Over")
  {
    fill(255);
    textSize(50);
    text("GAME OVER", 225, 350);
    textSize(25);
    text("Click anywhere on the screen or wait to continue.", 80, 500);

    if (timer % 400 == 0)
    {
      if (beatHighScore() == true)
      {
        firstInitial.onSlot = 0;
        secondInitial.onSlot = 0;
        thirdInitial.onSlot = 0;

        gameState = "Enter Initials";
      } else 
      {
        gameState = "Menu";
      }
    }
  }
}

// =============================================================================================================== //
// =================================================  MOUSE  ===================================================== //
// =============================================================================================================== //

void mousePressed()
{
  if (gameState == "Menu")
  {
    if (mouseX >= play.x && mouseX <= play.x + play.w && mouseY >= play.y && mouseY <= play.y + play.h)
    {
      play.textColor = color (255, 255, 255); //Change color of the button
      exit.textColor = color (0, 0, 0);
      pause.textColor = color (0, 0, 0);

      //Initialize "In Game" variables
      timer = 0;
      level = 1;
      linesCleared = 0;
      points = 0;
      speed = 50;
      stationary = false;
      playing = true;
      pause.font = 23;
      pause.buttonText = "PAUSE";

      //Add a Tetrominto the starting of the game
      for (int i = 0; i < 1; i ++)
      {
        Tetromino t = new Tetromino();
        tetrominos.add(t);
      }

      //Change the game state
      gameState = "In Game";
    } else if (mouseX >= instructions.x && mouseX <= instructions.x + instructions.w && mouseY >= instructions.y && mouseY <= instructions.y + instructions.h)
    {   
      //Change the game state
      gameState = "Instructions";
      backToMenu.textColor = color (0, 0, 0);
    } else if (mouseX >= leaderboard.x && mouseX <= leaderboard.x + leaderboard.w && mouseY >= leaderboard.y && mouseY <= leaderboard.y + leaderboard.h)
    {
      //Change the game state
      gameState = "Leaderboard";
      backToMenu.textColor = color (0, 0, 0);
    }
  } else if (gameState == "Leaderboard" || gameState == "Instructions")
  {
    if (mouseX >= backToMenu.x && mouseX <= backToMenu.x + backToMenu.w && mouseY >= backToMenu.y && mouseY <= backToMenu.y + backToMenu.h)
    {
      //Colors of all buttons are adjusted
      play.textColor = color (255, 255, 255);
      instructions.textColor = color (255, 255, 255);
      leaderboard.textColor = color (255, 255, 255);

      //Change the game state
      gameState = "Menu";
    }
  } else if (gameState == "Enter Initials")
  {
    if (mouseX >= firstInitial.x && mouseX <= firstInitial.x + firstInitial.w && mouseY >= firstInitial.y && mouseY <= firstInitial.y + firstInitial.h)
    {
      firstInitial.clicked();
    } else if (mouseX >= secondInitial.x && mouseX <= secondInitial.x + secondInitial.w && mouseY >= secondInitial.y && mouseY <= secondInitial.y + secondInitial.h)
    {
      secondInitial.clicked();
    } else if (mouseX >= thirdInitial.x && mouseX <= thirdInitial.x + thirdInitial.w && mouseY >= thirdInitial.y && mouseY <= thirdInitial.y + thirdInitial.h)
    {
      thirdInitial.clicked();
    } else if (mouseX >= submit.x && mouseX <= submit.x + submit.w && mouseY >= submit.y && mouseY <= submit.y + submit.h)
    {
      playerIns = alphabet[firstInitial.onSlot] + alphabet[secondInitial.onSlot] + alphabet[thirdInitial.onSlot]; //Initials of player are finalized

      //Exact placement of player is checker
      checkPlacement();

      backToMenu.textColor = color (0, 0, 0);

      //Change game state
      gameState = "Leaderboard";
    }
  } else if (gameState == "In Game")
  {
    if (mouseX >= exit.x && mouseX <= exit.x + exit.w && mouseY >= exit.y && mouseY <= exit.y + exit.h)
    {
      play.textColor = color (255, 255, 255);
      instructions.textColor = color (255, 255, 255);
      leaderboard.textColor = color (255, 255, 255);

      //Both array lists are cleared of their elements
      tetrominos.clear();
      allBlocks.clear();

      //Change the game state
      gameState = "Menu";
    } else if ((mouseX >= pause.x && mouseX <= pause.x + pause.w && mouseY >= pause.y && mouseY <= pause.y + pause.h) && playing == true)
    {
      playing = false;
      pause.font = 30;
      pause.buttonText = "PLAY";
    } else if ((mouseX >= pause.x && mouseX <= pause.x + pause.w && mouseY >= pause.y && mouseY <= pause.y + pause.h) && playing == false)
    {
      playing = true;
      pause.font = 23;
      pause.buttonText = "PAUSE";
    }
  } else if (gameState == "Game Over")
  {
    if (beatHighScore() == true)
    {
      firstInitial.onSlot = 0;
      secondInitial.onSlot = 0;
      thirdInitial.onSlot = 0;

      gameState = "Enter Initials";
    } else 
    {
      gameState = "Menu";
    }
  }
}

void mouseMoved()
{
  if (gameState == "Menu")
  {
    if (mouseX >= play.x && mouseX <= play.x + play.w && mouseY >= play.y && mouseY <= play.y + play.h)
    {
      play.textColor = color (76, 89, 142); //Change the color of the text if mouse hovers over the button
    } else if (mouseX >= instructions.x && mouseX <= instructions.x + instructions.w && mouseY >= instructions.y && mouseY <= instructions.y + instructions.h)
    {
      instructions.textColor = color (76, 89, 142); //Change the color of the text if mouse hovers over the button
    } else if (mouseX >= leaderboard.x && mouseX <= leaderboard.x + leaderboard.w && mouseY >= leaderboard.y && mouseY <= leaderboard.y + leaderboard.h)
    {
      leaderboard.textColor = color (76, 89, 142); //Change the color of the text if mouse hovers over the button
    } else
    {
      play.textColor = color (255, 255, 255);
      instructions.textColor = color (255, 255, 255);
      leaderboard.textColor = color (255, 255, 255);
    }
  } else if (gameState == "Leaderboard" || gameState == "Instructions")
  {
    if (mouseX >= backToMenu.x && mouseX <= backToMenu.x + backToMenu.w && mouseY >= backToMenu.y && mouseY <= backToMenu.y + backToMenu.h)
    {
      backToMenu.textColor = color (41, 90, 164);
    } else
    {
      backToMenu.textColor = color (0, 0, 0);
    }
  } else if (gameState == "Enter Initials")
  {
    if (mouseX >= submit.x && mouseX <= submit.x + submit.w && mouseY >= submit.y && mouseY <= submit.y + submit.h)
    {
      submit.textColor = color (41, 90, 164);
    } else
    {
      submit.textColor = color (0, 0, 0);
    }
  } else if (gameState == "In Game")
  {
    if (mouseX >= exit.x && mouseX <= exit.x + exit.w && mouseY >= exit.y && mouseY <= exit.y + exit.h)
    {
      exit.textColor = color (41, 90, 164);
    } else
    {
      exit.textColor = color (0, 0, 0);
    } 

    if (mouseX >= pause.x && mouseX <= pause.x + pause.w && mouseY >= pause.y && mouseY <= pause.y + pause.h)
    {
      pause.textColor = color (41, 90, 164);
    } else
    {
      pause.textColor = color (0, 0, 0);
    }
  }
}

// =============================================================================================================== //
// ================================================  KEYBOARD  =================================================== //
// =============================================================================================================== //

void keyPressed()
{
  if (gameState == "In Game")
  {
    for (int i = 0; i < tetrominos.size(); i ++)
    {
      Tetromino a = tetrominos.get(i);

      //When the UP arrow key is pressed, each shape is rotated by 90 degrees
      if (keyCode == UP && playing == true)
      {
        //For all tiles, block 2 serves as the rotation point. Therefore, if block 2 is touching the walls of the playing field or other blocks, the shape should not rotate
        if (a.x2 != playField.x && a.x2 + a.w != playField.x + playField.w && checkCollisionTetrominoBlocks("Block Two Collision", a.x1, a.y1, a.x2, a.y2, a.x3, a.y3, a.x4, a.y4, a.w, a.h) == false)
        {
          //The rotation will occur depending on the type of Tetromino because depending on the type of shape, the number of possible rotations vary
          if (a.shapeType == 1 && a.x2 + a.w + a.w != playField.x + playField.w && a.y2 + a.h + a.h != playField.y + playField.h && checkCollisionTetrominoBlocks("Block Two Collision", a.x1, a.y1, a.x2 + a.w, a.y2, a.x3, a.y3, a.x4, a.y4, a.w, a.h) == false && checkCollisionTetrominoBlocks("Block Two Collision", a.x1, a.y1, a.x2, a.y2 + a.h + a.h, a.x3, a.y3, a.x4, a.y4, a.w, a.h) == false)
          {
            if (a.rotation < 2)
            {
              a.rotation ++;
            } else 
            {
              a.rotation = 1;
            }

            a.rotateTetromino(); //Execute rotation
          } else if (a.shapeType == 3)
          {
            if (a.rotation < 4)
            {
              a.rotation ++;
            } else 
            {
              a.rotation = 1;
            }

            a.rotateTetromino();
          } else if (a.shapeType == 4)
          {
            if (a.rotation < 2)
            {
              a.rotation ++;
            } else 
            {
              a.rotation = 1;
            }

            a.rotateTetromino();
          } else if (a.shapeType == 5)
          {
            if (a.rotation < 2)
            {
              a.rotation ++;
            } else 
            {
              a.rotation = 1;
            }

            a.rotateTetromino();
          } else if (a.shapeType == 6)
          {
            if (a.rotation < 4)
            {
              a.rotation ++;
            } else 
            {
              a.rotation = 1;
            }

            a.rotateTetromino();
          } else if (a.shapeType == 7)
          {
            if (a.rotation < 4)
            {
              a.rotation ++;
            } else 
            {
              a.rotation = 1;
            }

            a.rotateTetromino();
          }
        }
      } else if (keyCode == RIGHT && checkCollisionTetrominoBlocks("right", a.x1, a.y1, a.x2, a.y2, a.x3, a.y3, a.x4, a.y4, a.w, a.h) == false && playing == true)
      {
        //Tetromino will move right using the RIGHT arrow key, given that the movement does not result in a collision
        a.moveTetrominoLaterally("right");
      } else if (keyCode == LEFT && checkCollisionTetrominoBlocks("left", a.x1, a.y1, a.x2, a.y2, a.x3, a.y3, a.x4, a.y4, a.w, a.h) == false && playing == true)
      {
        //Tetromino will move left using the LEFT arrow key, given that the movement does not result in a collision
        a.moveTetrominoLaterally("left");
      } else if (keyCode == DOWN && playing == true)
      {
        //Change the speed of the Tetromino if DOWN arrow is pressed to accelerate the descending
        speed = 2;
      }
    }
  }
}

void keyReleased()
{
  if (gameState == "In Game")
  {
    if (keyCode == DOWN)
    {
      if (level == 1)
      {
        speed = 50;
      } else if (level == 2)
      {
        speed = 40;
      } else if (level == 3)
      {
        speed = 30;
      } else if (level == 4)
      {
        speed = 20;
      } else if (level == 5)
      {
        speed = 15;
      }
    }
  }
}

// =============================================================================================================== //
// ==============================================  OTHER METHODS  ================================================ //
// =============================================================================================================== //

//Check collision of Tetromino with other Blocks
boolean checkCollisionTetrominoBlocks(String movementDirection, float newX1, float newY1, float newX2, float newY2, float newX3, float newY3, float newX4, float newY4, float w, float h)
{
  boolean collided = false;

  for (int i = 0; i < allBlocks.size(); i ++)
  {
    Block b = allBlocks.get(i);

    if (movementDirection == "Block Two Collision")
    {
      //Check RectRect collision of a block and square 2 of the Tetromino
      if (collideRectRectLocation(newX2, newY2, w, h, b.x, b.y, b.w, b.h) == "left" || collideRectRectLocation(newX2, newY2, w, h, b.x, b.y, b.w, b.h) == "right")
      {
        collided = true;
      }
    } else
    {
      if (collideRectRectLocation(newX1, newY1, w, h, b.x, b.y, b.w, b.h) == movementDirection || collideRectRectLocation(newX2, newY2, w, h, b.x, b.y, b.w, b.h) == movementDirection || collideRectRectLocation(newX3, newY3, w, h, b.x, b.y, b.w, b.h) == movementDirection || collideRectRectLocation(newX4, newY4, w, h, b.x, b.y, b.w, b.h) == movementDirection)
      {
        collided = true;
      }
    }
  } 

  return collided;
}

String collideRectRectLocation (float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  if (x1 <= x2+w2 && x1+w1 >= x2 && y1 <= y2+h2 && y1+h1 >= y2) {
    float collisionLeft = x2 + w2 - x1;
    float collisionRight = x1 + w1 - x2;
    float collisionTop = y2 + h2 - y1;
    float collisionBottom = y1 + h1 - y2;
    if (collisionLeft <= collisionBottom && collisionLeft <= collisionTop && collisionLeft <= collisionRight)
    {
      //Checking for the collision of the vertex of two rectangles
      if ((x2 + w2 == x1 && y2 + h2 == y1) || (x1 == x2 + w2 && y1 + h1 == y2))
        return "none";

      return "left";
    } else if (collisionRight <= collisionBottom && collisionRight <= collisionTop && collisionRight <= collisionLeft)
    {
      //Checking for the collision of the vertex of two rectangles
      if ((x1 + w1 == x2 && y1 == y2 + h2) || (x1 + w1 == x2 && y1 + h1 == y2))
        return "none";

      return "right";
    } else if (collisionTop <= collisionBottom && collisionTop <= collisionLeft && collisionTop <= collisionRight)
      return "top" ;
    else if (collisionBottom <= collisionTop && collisionBottom <= collisionLeft && collisionBottom <= collisionRight) 
    {
      if ((x2 + w2 == x1 && y2 + h2 == y1) || (x1 == x2 + w2 && y1 + h1 == y2) || (x1 + w1 == x2 && y1 == y2 + h2) || (x1 + w1 == x2 && y1 + h1 == y2))
        return "none";

      return "bottom" ;
    }
  }
  return "none";
}

//Check individual rows of playField for 10 blocks
void checkingRows()
{
  int numLinesCleared = 0; //Variable for number of lines cleared in one time

  for (int row = int(playField.y + playField.h - 35); row >= playField.y; row = row - 35)
  {
    int blockCounter = 0;

    //Count the number of blocks in the row
    for (int i = 0; i < allBlocks.size(); i ++)
    { 
      Block b = allBlocks.get(i);

      if (b.y == row)
      {
        blockCounter ++;
      }
    }

    //If there are 10 blocks in the designated row, remove the ten blocks, and move the blocks above the row down
    if (blockCounter == 10)
    {
      for (int j = allBlocks.size() - 1; j >= 0; j --)
      {  
        Block b = allBlocks.get(j);

        if (b.y == row)
        {
          allBlocks.remove(b);
        }
      }

      for (int j = 0; j < allBlocks.size(); j ++)
      {
        Block b = allBlocks.get(j);

        if (b.y < row)
        {
          b.y = b.y + 35;
        }
      }

      numLinesCleared ++; //Increment the variable for lines Cleared

      row = row + 35;
    }
  }

  //Award points to the user based on the number of lines cleared at one time
  if (numLinesCleared == 1)
  {
    points = points + 1000;
  } else if (numLinesCleared == 2)
  {
    points = points + 3000;
  } else if (numLinesCleared == 3)
  {
    points = points + 6000;
  } else if (numLinesCleared >= 4)
  {
    points = points + 10000;
  }

  //Determine the total number of lines cleared
  linesCleared = linesCleared + numLinesCleared;

  //Based on the total number of lines cleared, the level increases
  if (linesCleared == 5)
  {
    level = 2;
    speed = 40;
  } else if (linesCleared == 10)
  {
    level = 3;
    speed = 30;
  } else if (linesCleared == 15)
  {
    level = 4;
    speed = 20;
  } else if (linesCleared >= 20)
  {
    level = 5;
    speed = 15;
  }
}

void drawLogo()
{
  //Draw logo

  //Draw rectangles of logo
  noStroke();
  fill(41, 90, 164);

  rect(172.5, 80, 400, 150);
  rect(300, 160, 150, 175);

  //Draw outline of the logo
  stroke(223, 174, 80);
  strokeWeight(3);

  line(172.5, 80, 172.5, 228);
  line(172.5, 80, 574, 80);
  line(574, 80, 574, 228);
  line(172.5, 228, 300, 228);
  line(574, 228, 450, 228);
  line(300, 228, 300, 333);
  line(450, 228, 450, 333);
  line(300, 333, 450, 333);

  noStroke();

  //Draw 'T'
  fill(228, 54, 48);
  rect(180, 88, 60, 20);
  rect(201, 88, 20, 130);

  //Draw 'E'
  fill(236, 103, 54);
  rect(245, 88, 20, 130);
  quad(307, 200, 315, 218, 248, 218, 248, 200);
  quad(307, 88, 293, 107, 248, 107, 248, 88);
  quad(300, 128, 289, 144, 248, 144, 248, 128);

  //Draw 'T'
  fill(222, 215, 69);
  rect(311, 88, 60, 20);
  rect(331, 88, 20, 130);

  //Draw 'i'
  fill(126, 227, 247);
  rect(458, 120, 20, 85);
  rect(458, 88, 20, 20);

  //Draw 'R'
  fill(135, 240, 64);
  rect(381, 88, 20, 130);
  rect(381, 88, 55, 13);
  quad(415, 136, 400, 136, 433, 88, 447, 88);
  quad(424, 136, 400, 136, 447, 218, 469, 218);

  //Draw 'S'
  fill(165, 82, 209);
  rect(503, 88, 60, 20);
  quad(488, 88, 510, 88, 567, 220, 544, 220);
  rect(488, 200, 70, 20);

  stroke(0);
  strokeWeight(2);
}

void writeInstructions()
{
  fill(255);
  textSize(16);
  text("Description of the Game:", 7.5, 52);

  textSize(14);
  text("When the game begins, differently shaped tiles (called Tetrominos) will descend from the top of the playing", 7.5, 100);
  text("area. While each tile is descending, using controls listed below you have the ability to arrange the tiles", 7.5, 120);
  text("while they fill the playing area. The objective of the game is to complete as many full rows of blocks;", 7.5, 140);
  text("whenever this occurs, the row will disappear which will award you points. If you are unable to create", 7.5, 160);
  text("complete rows, the tiles will continue to fill the playing area. If the pieces reach the top of the screen, the", 7.5, 180);
  text("game will end.", 7.5, 200);

  text("You are able to move the Tetromino:", 7.5, 232);
  text("Using the LEFT arrow key", 67.5, 380);
  text("the tile will move left.", 82.5, 400);
  text("Using the RIGHT arrow key", 487.5, 380);
  text("the tile will move right.", 500, 400);
  text("Using the UP arrow key, the tile will", 240, 260);
  text("rotate 90 degrees.", 295, 280);
  text("Using the DOWN arrow key, you", 255, 440);
  text("can increase the downward acceleration", 225, 460);
  text("of the tile.", 319, 480);

  textSize(16);
  text("Scoring System:", 7.5, 532);

  textSize(14);
  text("During the game, you will be awarded points based on the number of complete rows formed in one time.", 7.5, 580);
  text("The scoring system is as follows:", 7.5, 620);
  text("     -   For one full row created: 1000 points awarded", 7.5, 640);
  text("     -   For two full rows created: 3000 points awarded", 7.5, 660);
  text("     -   For three full rows created: 6000 points awarded", 7.5, 680);
  text("     -   For four full rows created: 10000 points awarded", 7.5, 700);
  text("Moreover, if you are able to beat one of the high scores displayed on the leaderboard, you will be displayed", 7.5, 725);
  text("on the leaderboard.", 7.5, 745);

  fill(56, 153, 216);
  stroke(255);

  rect(337.5, 300, 50, 40);
  rect(337.5, 360, 50, 40);
  rect(413, 360, 50, 40);
  rect(263, 360, 50, 40);

  fill(165, 82, 209);
  noStroke();
  triangle(278, 384, 300, 376, 300, 392);
  triangle(428, 392, 428, 376, 450, 384);
  triangle(362, 306, 354, 330, 369, 330);
  triangle(362, 396, 354, 372, 369, 372);
}

void drawLeaderboard()
{
  textSize(50);
  fill(255);
  text ("HIGH SCORES", 193, 160);

  textSize(25);
  text (firstPlace.playerInitials, 280, 280);
  text (secondPlace.playerInitials, 115, 380);
  text (thirdPlace.playerInitials, 450, 460);
  text (firstPlace.score, 355, 280);
  text (secondPlace.score, 188, 380);
  text (thirdPlace.score, 525, 460);

  noStroke();

  fill(238, 84, 84);
  rect(112, 400, 150, 200);
  rect(277.5, 300, 150, 300);
  rect(442, 480, 150, 120);

  fill(202, 71, 72);
  rect(243, 400, 35, 200);
  rect(409, 300, 35, 300);
  rect(574, 480, 35, 120);

  fill(209, 209, 209);
  ellipse(130, 440, 100, 100);

  fill(253, 224, 76);
  ellipse(295, 360, 100, 100);

  fill(205, 127, 51);
  ellipse(460, 490, 100, 100);

  fill(0);
  textSize(40);
  text("2", 168, 506);
  text("1", 332, 428);
  text("3", 495, 556);
}

boolean beatHighScore()
{
  if (points >= firstPlace.score || points >= secondPlace.score || points >= thirdPlace.score)
  {
    return true;
  } else
    return false;
}

//Check placement of player on leaderboard
void checkPlacement()
{
  //Update leaderboard scores and names based on the placement
  if (points >= firstPlace.score)
  {
    thirdPlace.score = secondPlace.score;
    secondPlace.score = firstPlace.score;
    firstPlace.score = points;

    thirdPlace.playerInitials = secondPlace.playerInitials;
    secondPlace.playerInitials = firstPlace.playerInitials;
    firstPlace.playerInitials = playerIns;
  } else if (points >= secondPlace.score)
  {
    thirdPlace.score = secondPlace.score;
    secondPlace.score = points;

    thirdPlace.playerInitials = secondPlace.playerInitials;
    secondPlace.playerInitials = playerIns;
  } else if (points >= thirdPlace.score)
  {
    thirdPlace.score = points;

    thirdPlace.playerInitials = playerIns;
  }
}

// =============================================================================================================== //
// ===============================================  CLASSES  ===================================================== //
// =============================================================================================================== //

class PlayField
{
  float x, y, w, h;

  PlayField()
  {
    x = 50;
    y = 75;
    w = 10 * 35; //Play field has a width of 10 units. Each unit is 35 pixels
    h = 20 * 35; //Play field has a height of 20 units. Each unit is 35 pixels
  }

  void drawPlayField()
  {
    fill(255);
    strokeWeight(3);
    stroke(255);

    //Draw rectangular playing field
    rect(x, y, w, h);
  }
}

class Tetromino
{
  float x1, y1, x2, y2, x3, y3, x4, y4, w, h;
  color tetrominoColor;
  //int shapeType = 1;
  int shapeType = (int) random(1, 8); //Indicates the type of shape which is randomly generated
  int rotation = 1;

  //Constructor
  Tetromino()
  {
    //Each unit is 35 pixels in length and width
    w = 35;
    h = 35;

    //Depending on each type of tile, each one of the four squares will have different x and y coordinates
    if (shapeType == 1) //'I' Shape
    {
      tetrominoColor = color (126, 227, 247); //Different color for each tile

      x2 = playField.x + w * 4;
      y2 = playField.y - h * 2;
      x1 = x2;
      y1 = y2 - h;
      y2 = y1 + h;
      x3 = x2;
      y3 = y2 + h;
      x4 = x2;
      y4 = y3 + h;
    } else if (shapeType == 2) //'O' Shape
    {
      tetrominoColor = color (253, 224, 76);

      x2 = playField.x + w * 5;
      y2 = playField.y - h;
      x1 = x2 - w;
      y1 = y2;
      x3 = x1;
      y3 = y1 + h;
      x4 = x2;
      y4 = y3;
    } else if (shapeType == 3) //'T' Shape
    {
      tetrominoColor = color (165, 82, 209);

      x2 = playField.x + w * 4;
      y2 = playField.y - h;
      x1 = x2 - w;
      y1 = y2;
      x3 = x2 + w;
      y3 = y1;
      x4 = x2;
      y4 = y2 + h;
    } else if (shapeType == 4) //'S' Shape
    {
      tetrominoColor = color (135, 240, 64);

      x2 = playField.x + w * 4;
      y2 = playField.y - h;
      x1 = x2 + w;
      y1 = y2;
      x3 = x2;
      y3 = y2 + h;
      x4 = x3 - w;
      y4 = y3;
    } else if (shapeType == 5) //'Z' Shape
    {
      tetrominoColor = color (228, 54, 48);

      x2 = playField.x + w * 4;
      y2 = playField.y - h;
      x1 = x2 - w;
      y1 = y2;
      x3 = x2;
      y3 = y2 + h;
      x4 = x3 + w;
      y4 = y3;
    } else if (shapeType == 6) //'L' Shape
    {
      tetrominoColor = color (243, 149, 62);

      x2 = playField.x + w * 4;
      y2 = playField.y - h;
      x1 = x2 - w;
      y1 = y2;
      x3 = x2 + w;
      y3 = y1;
      x4 = x1;
      y4 = y1 + h;
    } else if (shapeType == 7) //'J' Shape
    {
      tetrominoColor = color (41, 90, 164);

      x2 = playField.x + w * 4;
      y2 = playField.y;
      x1 = x2 - w;
      y1 = y2;
      x3 = x2 + w;
      y3 = y2;
      x4 = x1;
      y4 = y1 - h;
    }
  }

  void rotateTetromino()
  {
    //To rotate the shape the x and y coordinates are adjusted for each type of tile

    if (shapeType == 1 && rotation == 1)
    {  
      x1 = x1 + w;
      y1 = y1 - h;
      x3 = x3 - w;
      y3 = y3 + h;
      x4 = x4 - w - w;
      y4 = y4 + h + h;
    } else if (shapeType == 1 && rotation == 2)
    {
      x1 = x1 - w;
      y1 = y1 + h;
      x3 = x3 + w;
      y3 = y3 - h;
      x4 = x4 + w + w;
      y4 = y4 - h - h;
    } else if (shapeType == 3 && rotation == 1)
    {
      x1 = x1 - w;
      y1 = y1 - h;
      x3 = x3 + w;
      y3 = y3 + h;
      x4 = x4 - w;
      y4 = y4 + h;
    } else if (shapeType == 3 && rotation == 2)
    {
      x1 = x1 + w;
      y1 = y1 - h;
      x3 = x3 - w;
      y3 = y3 + h;
      x4 = x4 - w;
      y4 = y4 - h;
    } else if (shapeType == 3 && rotation == 3)
    {
      x1 = x1 + w;
      y1 = y1 + h;
      x3 = x3 - w;
      y3 = y3 - h;
      x4 = x4 + w;
      y4 = y4 - h;
    } else if (shapeType == 3 && rotation == 4)
    {
      x1 = x1 - w;
      y1 = y1 + h;
      x3 = x3 + w;
      y3 = y3 - h;
      x4 = x4 + w;
      y4 = y4 + h;
    } else if (shapeType == 4 && rotation == 1)
    {
      x1 = x1 + w;
      y1 = y1 + h;
      x3 = x3 - w;
      y3 = y3 + h;
      x4 = x4 - w - w;
    } else if (shapeType == 4 && rotation == 2)
    {
      x1 = x1 - w;
      y1 = y1 - h;
      x3 = x3 + w;
      y3 = y3 - h;
      x4 = x4 + w + w;
    } else if (shapeType == 5 && rotation == 1)
    {
      x1 = x1 - w;
      y1 = y1 + h;
      x3 = x3 + w;
      y3 = y3 + h;
      x4 = x4 + w + w;
    } else if (shapeType == 5 && rotation == 2)
    {
      x1 = x1 + w;
      y1 = y1 - h;
      x3 = x3 - w;
      y3 = y3 - h;
      x4 = x4 - w - w;
    } else if (shapeType == 6 && rotation == 1)
    {
      x1 = x1 - w;
      y1 = y1 - h;
      x3 = x3 + w;
      y3 = y3 + h;
      x4 = x4 - w - w;
    } else if (shapeType == 6 && rotation == 2)
    {
      x1 = x1 + w;
      y1 = y1 - h;
      x3 = x3 - w;
      y3 = y3 + h;
      y4 = y4 - h - h;
    } else if (shapeType == 6 && rotation == 3)
    {
      x1 = x1 + w;
      y1 = y1 + h;
      x3 = x3 - w;
      y3 = y3 - h;
      x4 = x4 + w + w;
    } else if (shapeType == 6 && rotation == 4)
    {
      x1 = x1 - w;
      y1 = y1 + h;
      x3 = x3 + w;
      y3 = y3 - h;
      y4 = y4 + h + h;
    } else if (shapeType == 7 && rotation == 1)
    {
      x1 = x1 - w;
      y1 = y1 - h;
      x3 = x3 + w;
      y3 = y3 + h;
      y4 = y4 - h - h;
    } else if (shapeType == 7 && rotation == 2)
    {
      x1 = x1 + w;
      y1 = y1 - h;
      x3 = x3 - w;
      y3 = y3 + h;
      x4 = x4 + w + w;
    } else if (shapeType == 7 && rotation == 3)
    {
      x1 = x1 + w;
      y1 = y1 + h;
      x3 = x3 - w;
      y3 = y3 - h;
      y4 = y4 + h + h;
    } else if (shapeType == 7 && rotation == 4)
    {
      x1 = x1 - w;
      y1 = y1 + h;
      x3 = x3 + w;
      y3 = y3 - h;
      x4 = x4 - w - w;
    }
  }

  void moveTetromino()
  {
    //To descend the tetromino, increase the y coordinates of each block by the height    
    y1 = y1 + h;
    y2 = y2 + h;
    y3 = y3 + h;
    y4 = y4 + h;
  }

  void moveTetrominoLaterally(String direction)
  {
    if (direction == "right")
    {
      x1 = x1 + w;
      x2 = x2 + w;
      x3 = x3 + w;
      x4 = x4 + w;
    } else if (direction == "left")
    {
      x1 = x1 - w;
      x2 = x2 - w;
      x3 = x3 - w;
      x4 = x4 - w;
    }
  }

  void collisionWithWalls()
  {
    //Correct positions of each block if the Tetromino collides with the boundary
    if (x1 + w <= playField.x || x2 + w <= playField.x || x3 + w <= playField.x || x4 + w <= playField.x)
    {
      x1 = x1 + w;
      x2 = x2 + w;
      x3 = x3 + w;
      x4 = x4 + w;
    } else if (x1 >= playField.x + playField.w || x2 >= playField.x + playField.w || x3 >= playField.x + playField.w || x4 >= playField.x + playField.w)
    {
      x1 = x1 - w;
      x2 = x2 - w;
      x3 = x3 - w;
      x4 = x4 - w;
    }
  }

  boolean collisionWithBottom()
  {
    if (y1 + h >= playField.y + playField.h || y2 + h >= playField.y + playField.h || y3 + h >= playField.y + playField.h || y4 + h >= playField.y + playField.h)
    {
      return true;
    } else
    {
      return false;
    }
  }

  void drawTetromino()
  {
    fill(tetrominoColor);
    stroke(255);

    rect(x1, y1, w, h);
    rect(x2, y2, w, h);
    rect(x3, y3, w, h);
    rect(x4, y4, w, h);
  }
}

class Block
{
  float x, y, w, h;
  color clr, strokeSize;

  Block(float newX, float newY, float newW, float newH, color colorBlock)
  {
    x = newX;
    y = newY;
    w = newW;
    h = newH;
    clr = colorBlock;
    strokeSize = 255;
  }

  void drawBlock()
  {
    fill(clr);
    stroke(strokeSize);
    rect(x, y, w, h);
  }
}

class Button
{
  float x, y, w, h, font;
  color buttonColor;
  color textColor;
  color borderColor;
  String buttonText;

  //Constructor
  Button (float newX, float newY, float newW, float newH, color button, color border, float fontSize, color txt, String text)
  {
    x = newX;
    y = newY;
    w = newW;
    h = newH;
    buttonColor = button;
    borderColor = border;
    font = fontSize;
    textColor = txt;
    buttonText = text;
  } 

  void drawButton()
  {
    fill (buttonColor);
    stroke(borderColor);
    rect(x, y, w, h, 7);

    fill(textColor);
    textSize(font);
    text(buttonText, x + 7.5, y + 28);
  }
}

class Letter
{
  float x, y, w, h;
  int onSlot = 0; //Letter "A"

  Letter(float newx, float newy, float neww, float newh)
  {
    x = newx;
    y = newy;
    w = neww;
    h = newh;
  }

  void drawLetter()
  {

    fill (180, 207, 236);
    triangle(x + w*0.05, y + h*0.20, x + w*0.5, y + h*0.05, x + w*0.95, y + h*0.20);

    fill (180, 207, 236);
    triangle(x + w*0.05, y + h*0.80, x + w*0.5, y + h*0.95, x + w*0.95, y + h*0.80);

    fill(255);
    textSize(80);
    text (alphabet[onSlot], x + w*0.35, y + h*0.65);
  }

  void clicked()
  {
    //up arrow
    if (mouseY <= y + h *0.20)
    {
      onSlot = onSlot + 1;
      if (onSlot == alphabet.length)
        onSlot = 0;
    } else if (mouseY >= y + h *0.80)
    {
      onSlot = onSlot - 1;
      if (onSlot == -1)
        onSlot = alphabet.length - 1;
    }
  }
}

class HighScore
{
  String playerInitials;
  int score;
}
