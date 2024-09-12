#!/bin/bash

# Initialize variables
x=20  # Snake's initial x position
y=15  # Snake's initial y position
prev_x=$x
prev_y=$y
width=80  # Increase width to desired size 
height=36  # Increase height to desired size 
score=0    # Initialize score

# Direction variables
direction="d"  # Default direction is right

# Function to generate a random position for the food
generate_food_position() {
    food_x=$((RANDOM % (width - 1) + 1))
    food_y=$((RANDOM % (height - 1) + 1))
}

# Generate the initial position of the food
generate_food_position

# Hide cursor and clear the screen
tput civis
tput clear

# Function to draw the boundary
draw_boundary() {
    # Draw top and bottom boundary
    for ((i=0; i<=width; i++)); do
        tput cup 0 $i
        echo "#"
        tput cup $height $i
        echo "#"
    done
    
    # Draw left and right boundary
    for ((i=0; i<=height; i++)); do
        tput cup $i 0
        echo "#"
        tput cup $i $width
        echo "#"
    done
}

# Function to display the score and time left
display_info() {
    tput cup $((height + 1)) 0
    echo -e "Score: $score\t\tTime Left: $((30 - elapsed_time)) secs"
}

# Draw static elements once
tput clear
draw_boundary
display_info
ii
# Record the start time
start_time=$(date +%s)

# Game loop
while true; do
    # Read user input for snake movement (non-blocking)
    read -n 1 -s -t 0.01 key
    if [[ $key == $'\x1b' ]]; then
        # Handle escape sequences for arrow keys
        read -n 2 -s -t 0.01 key
        case $key in
            '[A') direction="w" ;;  # Arrow up
            '[B') direction="s" ;;  # Arrow down
            '[C') direction="d" ;;  # Arrow right
            '[D') direction="a" ;;  # Arrow left
        esac
    else
        case $key in
            w) direction="w" ;;  # Move up
            s) direction="s" ;;  # Move down
            a) direction="a" ;;  # Move left
            d) direction="d" ;;  # Move right
        esac
    fi

    # Erase the previous position of the snake
    tput cup $prev_y $prev_x
    echo " "  # Erase with a blank space

    # Update snake's current position
    case $direction in
        w) ((y--)) ;;  # Move up
        s) ((y++)) ;;  # Move down
        a) ((x--)) ;;  # Move left
        d) ((x++)) ;;  # Move right
    esac

    tput cup $y $x
    echo "S"  # Draw the snake's head

    # Draw the food
    tput cup $food_y $food_x
    echo "*"

    # Save the current position as previous
    prev_x=$x
    prev_y=$y

    # Check if snake has eaten the food
    if ((x == food_x && y == food_y)); then
        # Increment the score
        ((score++))
        # Generate a new food position
        generate_food_position
        # Update the score display
        display_info
    fi

    # End game if snake hits the boundaries
    if ((x <= 0 || x >= width || y <= 0 || y >= height)); then
        break
    fi

    # Check elapsed time
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if ((elapsed_time >= 30)); then
        break
    fi

    # Update the score and time left display continuously
    display_info

    # Delay to control game speed
    sleep 0.08
done

# Restore the terminal to normal
tput cnorm
tput clear
echo "Game Over! Your score is: $score"
