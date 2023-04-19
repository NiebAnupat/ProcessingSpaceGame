import java.util.Scanner;

class Laser {
    float x;
    float y;
    float speed;
    color c;
    
    public Laser(float x, float y, float speed, color c) {
        this.x = x;
        this.y = y;
        this.speed = speed;
        this.c = c;
    }
    
    void display() {
        stroke(c);
        strokeWeight(7.5);
        point(x, y);
    }
    
    void move() {
        y -= speed;
    }
    
    void enemyMove() {
        y += speed;
    }
}

class EnemyShip {
    PImage enemyShip;
    float x;
    float y;
    float speed;
    int health;
    ArrayList<Laser> lasers;
    
    public EnemyShip() {
        enemyShip = loadImage("enemyShip.png");
        enemyShip.resize(75, 75);
        x = random(width);
        y = 0;
        speed = 2;
        health = 3;
        lasers = new ArrayList<Laser>();
    }
    
    void display() {
        push();
        translate(x, y);
        // flip the image vertically
        scale(1, -1);
        
        image(enemyShip, -enemyShip.width / 2, -enemyShip.height / 2);
        pop();
    }
    
    void move() {
        y += speed;
    }
    
    boolean hitBy(Laser laser) {
        float distance = dist(x, y, laser.x, laser.y);
        if (distance < 50 && laser.y < y) { // check if laser hits from top
            health -= 1;
            return true;
        } else {
            return false;
        }
    }
    
    void shoot(PlayerShip player) {
        float dx = player.x - x;
        float dy = player.y - y;
        float angle = atan2(dy, dx);
        lasers.add(new Laser(x, y, 7, color(255, 0, 0)));
    }
    
    boolean isDead() {
        if (health <= 0) {
            return true;
        } else {
            return false;
        }
    }
}

class EnemyShipManager {
    ArrayList<EnemyShip> enemies = new ArrayList<EnemyShip>();
    
    void spawnEnemy() {
        enemies.add(new EnemyShip());
    }
    
    void display() {
        for (int i = enemies.size() - 1; i >= 0; i--) {
            EnemyShip enemy = enemies.get(i);
            enemy.display();
            enemy.move();
            
            if (enemy.y > height) {
                enemies.remove(i);
            }
            
            // Randomly shoot laser towards player
            if (random(100) < 1) {
                enemy.shoot(player);
            }
            
            // Check for collision with player lasers
            for (int j = player.lasers.size() - 1; j >= 0; j--) {
                Laser laser = player.lasers.get(j);
                if (enemy.hitBy(laser)) {
                    player.lasers.remove(j);
                    if (enemy.isDead()) {
                        enemies.remove(i);
                        score += 10;
                    }
                    break;
                }
            }
            
            // Check for collision with enemy lasers
            for (int j = enemy.lasers.size() - 1; j >= 0; j--) {
                Laser laser = enemy.lasers.get(j);
                if (player.hitBy(laser)) {
                    if (player.isDead()) {
                        gameOver = true;
                    } else{
                        enemy.lasers.remove(j);
                        break;
                    }
                }
            }
            
            // check for collision with enemy ship
            for (int j = enemies.size() - 1; j >= 0; j--) {
                EnemyShip enemy2 = enemies.get(j);
                if (enemy != enemy2) {
                    player.hitBy(enemy2);
                    if (player.isDead()) {
                        gameOver = true;
                    }
                }
            }
            
            
            // Move and display enemy lasers
            for (int j = enemy.lasers.size() - 1; j >= 0; j--) {
                Laser laser = enemy.lasers.get(j);
                laser.display();
                laser.enemyMove();
                if (laser.y > height) {
                    enemy.lasers.remove(j);
                }
            }
        }
        
    }
}


class PlayerShip {
    PImage playerShip;
    float x;
    float y;
    float angle;
    int health;
    ArrayList<Laser> lasers = new ArrayList<Laser>();
    boolean canTakeDamage;
    int lastHitTime;
    int hitDelay = 2000; // Delay in milliseconds
    
    
    public PlayerShip() {
        playerShip = loadImage("playerShip.png");
        playerShip.resize(100, 100);
        x = width / 2;
        y = height / 2;
        health = 3;
        canTakeDamage = true;
    }
    
    void display() {
        push();
        translate(x,y);
        // rotate(angle);
        image(playerShip, -playerShip.width / 2, -playerShip.height / 2);
        pop();
        
        // Display all lasers
        for (int i = lasers.size() - 1; i >= 0; i--) {
            Laser l = lasers.get(i);
            l.display();
            l.move();
            // Remove laser if it goes offscreen
            if (l.y < 0) {
                lasers.remove(i);
            }
        }
        
        // Check if enough time has passed since last hit
        if (!canTakeDamage && millis() - lastHitTime >= hitDelay) {
            canTakeDamage = true;
        }
    }
    
    void move() {
        float targetX = mouseX;
        float targetY = mouseY;
        
        // Set the speed of the ship's movement
        float speed = 0.1;
        
        // Use lerp to graduallymove the ship towards the mouse position
        x = lerp(x, targetX, speed);
        y = lerp(y, targetY, speed);
        
        // Shootlaser when mouseis clicked
        if (mousePressed) {
            int g = (int) random(0, 255);
            int b = (int) random(0, 255);
            
            // single laser
            lasers.add(new Laser(x, y, 10, color(255,174,66)));    
            
            
        }
        
    }
    
    boolean hitBy(EnemyShip enemy) {
        float distance = dist(x, y, enemy.x, enemy.y);
        if (distance < 50 && canTakeDamage) {
            health -= 1;
            canTakeDamage = false;
            lastHitTime = millis();
            return true;
        } else {
            return false;
        }
    }
    
    boolean hitBy(Laser laser) {
        float distance = dist(x, y, laser.x, laser.y);
        if (distance < 50) {
            health -= 1;
            return true;
        } else {
            return false;
        }
    }
    
    boolean isDead() {
        if (health <= 0) {
            return true;
        } else {
            return false;
        }
    }
}


PImage bg;
PImage heart;
PlayerShip player;
EnemyShipManager enemyManager;
boolean gameOver = false;
int score = 0;
int bestScore = 0;
void setup() {
    size(1280, 720);
    frameRate(240);
    bg = loadImage("bg.png");
    bg.resize(width,height);
    heart = loadImage("heart.png");
    heart.resize(50, 50);
    player = new PlayerShip();
    enemyManager = new EnemyShipManager();
    
    try {
        Scanner scanner = new Scanner(new File(this.sketchPath() + "\\bestScore.txt"));
        if (scanner.hasNextInt()) {
            bestScore = scanner.nextInt();
        } else{
            bestScore = 0;
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
}

void draw() {
    background(bg);
    
    textSize(20);
    textAlign(LEFT);
    fill(255);
    text("Score: " + score, 20, 30);
    fill(255, 255, 0);
    text("Best Score: " + bestScore, 20, 60);
    
    // Display health at right side of screen 
    for (int i = 0; i < player.health; i++) {
        image(heart, width - 60 - i * 55, 20);
    }
    
    player.display();
    player.move();
    
    // Spawn enemy ship randomly
    if (random(100) < 2) {
        enemyManager.spawnEnemy();
    }
    
    // Display and move all enemy ships
    enemyManager.display();
    
    if (gameOver) {
        background(bg);
        fill(255);
        textSize(50);
        textAlign(CENTER);
        fill(255, 0, 0);
        String txt = "GAME OVER";
        text(txt, width/2, height / 2);
        textSize(25);
        fill(255, 255, 0);
        txt = "Press 'r' to restart";
        text(txt, width/2, height / 2 + 50);
        
        try {
            PrintWriter writer = new PrintWriter(this.sketchPath() + "\\bestScore.txt");
            writer.println(bestScore);
            writer.flush();
            writer.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
        
        noLoop();
    }
    
    if (score > bestScore) {
        bestScore = score;
    }
}

void keyPressed() {
    if (gameOver) {
        if (key == 'r') {
            gameOver = false;
            enemyManager = new EnemyShipManager();
            player = new PlayerShip();
            score = 0;
            loop();
        }
    }
}