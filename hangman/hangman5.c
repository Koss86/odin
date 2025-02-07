#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>

int randNumber(int min, int max);           //
char getGuess();                            //
void gameStage(int lives, char *ansBoard);  //


typedef struct node {
    char alpha;
    bool guessed;
} node;

node aTab[26];

int main (void) {

    aTab[0].alpha='a';aTab[1].alpha='b';aTab[2].alpha='c';aTab[3].alpha='d';aTab[4].alpha='e';aTab[5].alpha='f';aTab[6].alpha='g';
    aTab[7].alpha='h';aTab[8].alpha='i';aTab[9].alpha='j';aTab[10].alpha='k';aTab[11].alpha='l';aTab[12].alpha='m';
    aTab[13].alpha='n';aTab[14].alpha='o';aTab[15].alpha='p';aTab[16].alpha='q';aTab[17].alpha='r';aTab[18].alpha='s';aTab[19].alpha='t';
    aTab[20].alpha='u';aTab[21].alpha='v';aTab[22].alpha='w';aTab[23].alpha='x';aTab[24].alpha='y';aTab[25].alpha='z';

    // Word list containing all available choices of words for game.
    char list[][12]={{"c o f f e e"},{"o f f i c e"},{"l a p t o p"},{"b e a u t y"},{"f r i e n d"},
                 {"g e n i u s"},{"r e w a r d"},{"d r i v e n"},{"c a m e r a"},{"c a s t l e"}};
    // Generate random number then put into variable 'key'.
    const int key= randNumber(0, 9);
    // Get length of random chosen word for search loop.
    int arrayLen= strlen(list[key]);
    int size= 6;
    int correct = 0;
    int lives= 6;
    char ansBoard[][12]={"_ _ _ _ _ _"};

            //print Welcome
    printf("\n   |#|============\n   |#|/          |\n   |#|       Welcome to          \n   |#|        Hangman!          \n   |#|          \n   |#|\n __|#|__\n\n");
    printf("You have 6 lives. Lose 1 for an incorrect guess.\nPlease use lowercase only.\n      Good luck!\nPress Enter to continue.");
    getchar();
    system("cls");

    ///// Debug Code ////////
    //printf("solution= %s\n\n", list[key]);
    ////////////////////////

    printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|\n   |#|\n   |#|\n   |#|\n___|#|___\n\n");
    printf("Lives: %d    %s\n\n", lives, ansBoard[0]);


    while (correct < 6 && lives > 0) {
        int counter = 0;

        char guess = getGuess();

        // Check user's guess with letters in key word, if match found, update ansBoard, add 1 to counter, add 1 to correct.
        for (int i = 0; i < arrayLen; i = i+2) { // checking every-other word because of spacing for asthetic reasons.
            if (list[key][i] - guess == 0) { 
                ansBoard[0][i] = guess;
                counter++;
                correct++;
            }
            //printf("Lives: %d    %s\n\n", lives, ansBoard); //debug for ansBoard
        }
        //printf("lives = %i correct = %i counter = %i\n", lives, correct, counter); //debug code for loop
        if (counter == 0) {
            lives--;
        }
        gameStage(lives, ansBoard[0]);
    }

    if (correct>=size) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|\n   |#|\n   |#|          \\O/\n   |#|           |\n___|#|___       / \\\n\n");
        printf("         -= %s =-\n", (char*)ansBoard);
        printf("          Congratulation!\n             You Won!\n\n");
    }
    if (lives<=0) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|           O\n   |#|          /|\\\n   |#|          / \\\n   |#|\n __|#|__\n\n");
        printf("    G A M E  O V E R\n        You Lost.\n\n The answer was: %c%c%c%c%c%c\n\n", list[key][0], list[key][2], list[key][4],
                                                                                                list[key][6], list[key][8], list[key][10]);
    }
    return 0;
}


char getGuess() {
    char guess=0;
    int counter=0;                          // Will remain 0 untill user makes a unique guess.
    int foundChar=0;

    while (counter == 0) {
        printf("You have guessed:\n");      //
                                            // This block checks if user guess has previously been guessed.
        for (int i = 0; i < 26; i++){       // If true, then it will print it out for user to see previously
            if (aTab[i].guessed == 1){      // guessed chars.
               printf(" %c", aTab[i].alpha);// 
                                            
            }                               
        }
        printf("\n");

        printf("Guess a letter:  ");
        scanf(" %c", &guess);
        for (int i = 0; i < 26; i++) {

            // Match user guess with matching aTab.alpha node
            if (aTab[i].alpha - guess == 0) {

                // If been guessed before, print warning and repeat loop, else add 1 to counter and exit loop.
                if (aTab[i].guessed == 1) {
                    printf("You have already guessed %c.\nPlease choose a different letter.\n\n", guess);
                }
                else {
                    counter++;
                    // foundChar will exit loop with correct index number to update aTab[].guessed below.
                    foundChar = i;
                }
            }
        }
    }
    // Update successful guess and return guess to main() guess variable.
    aTab[foundChar].guessed=1;   
    return guess;
}


void gameStage(int lives, char *ansBoard)
{
    if ( lives == 6) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|           \n   |#|\n   |#|\n   |#|\n __|#|__\n\n");
        printf("Lives               %s\n    %d\n\n", ansBoard, lives); 
    }
    else if (lives==5) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|           O\n   |#|\n   |#|\n   |#|\n __|#|__\n\n");
        printf("Lives               %s\n    %d\n\n", ansBoard, lives);
    }
    else if (lives==4) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|           O\n   |#|           |\n   |#|\n   |#|\n __|#|__\n\n");
        printf("Lives               %s\n    %d\n\n", ansBoard, lives);  
    }
    else if (lives==3) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|           O\n   |#|          /|\n   |#|\n   |#|\n __|#|__\n\n");
        printf("Lives               %s\n    %d\n\n", ansBoard, lives);  
    }
    else if (lives==2) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|           O\n   |#|          /|\\\n   |#|\n   |#|\n __|#|__\n\n");
        printf("Lives               %s\n    %d\n\n", ansBoard, lives);  
    }
    else if (lives==1) {
        printf("\n   |#|============\n   |#|/          |\n   |#|           |\n   |#|           O\n   |#|          /|\\\n   |#|          / \n   |#|\n __|#|__\n\n");
        printf("Lives               %s\n    %d\n\n", ansBoard, lives);  
    }
    return;
}

//////////Code from Stack Overflow///////
int randNumber(int min, int max)
{
    // Setting seed for the rand() function
    srand(time(0));

    // printf("Random number between %d and %d: ", min, max);

        // Find the random number in the given range
        // Generate a random number in the range [min, max]
        int rdNum = rand() % (max - min + 1) + min;
        return rdNum;
}