debug = true

-- Player Status
isAlive = true
score = 0

-- Timers
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Image storage
bulletImg = love.graphics.newImage('assets/bullet.png')
enemyImg = love.graphics.newImage('assets/enemy.png')

-- Bullet table
bullets = {} -- used to keep track of the bullets we will shoot
enemies = {} -- used to keep track of the enemies that we will spawn

player = { img = nil, x = 200, y = 550, speed = 150 } -- our player table/object

-- Called when the game first starts (load assets, etc.)
function love.load(arg)
   -- Loads the image into memory (assigning to player object)
   player.img = love.graphics.newImage('assets/plane.png')
end

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- Called every frame (takes delta time as an argument)
function love.update(dt)
   -- Provide a way to exit out of the game
   if love.keyboard.isDown('escape') then
      love.event.push('quit')
   end

   -- Respond to user left and right keystrokes in order to move the plane
   if love.keyboard.isDown('left','a') then
      if player.x > 0 then -- player must be at or to the right of the screen's left edge
         player.x = player.x - (player.speed*dt)  -- move player right
      end
   elseif love.keyboard.isDown('right','d') then
      --[[ player must be completely to the left of the screen's right edge
           this is ensured by substracting the sprite's width
           from the overall screen width --]]
      if player.x < (love.graphics:getWidth() - player.img:getWidth()) then
         player.x = player.x + (player.speed*dt) -- move player left
      end
   end

   -- Control shooting
   canShootTimer = canShootTimer - (1 * dt)
   if canShootTimer < 0 then
      canShoot = true
   end

   -- Respond to user space and control keystrokes in order to conditionally fire bullets
   if love.keyboard.isDown(' ','ctrl','lctrl','rctrl')  and canShoot then
      -- Fire the bullets, adding to the table
      newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
      -- Insert into to a table for tracking purposes
      table.insert(bullets, newBullet)
      -- Temporarily disable ability to shoot
      canShoot = false
      canShootTimer = canShootTimerMax
   end

   for i,bullet in ipairs(bullets) do
      bullet.y = bullet.y - (300 * dt) -- Make the bullet travel up the screen (up the y-axis) factoring in delta time
      if bullet.y < 0 then -- If the bullets fly off the screen
         table.remove(bullets, i) -- Remove them
      end
   end

   -- Control spawning of enemies
   createEnemyTimer = createEnemyTimer - (1 * dt) -- decrement timer
   if createEnemyTimer < 0 then -- check if time to create an enemy
      createEnemyTimer = createEnemyTimerMax -- reset timer
      xPos = love.math.random(10, love.graphics.getWidth() - 10) -- randomly generate x-coordinate for new enemy
      newEnemy = {x = xPos, y = -10, img = enemyImg} -- create new table for enemy to be spawned
      table.insert(enemies,newEnemy) -- insert into the enemies table to be tracked, etc.
   end

   -- Update the enemies' positions so that they can be drawn
   for i,enemy in ipairs(enemies) do
       enemy.y = enemy.y + (200 * dt)
       if enemy.y > love.graphics.getHeight() then
          table.remove(enemies,i)
       end
   end

   -- Check for collisions
   for i, enemy in ipairs(enemies) do
     for j, bullet in ipairs(bullets) do
         if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
            table.remove(enemies,i)
            table.remove(bullets,j)
            score = score + 1
         end
     end

     if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) and isAlive then
         table.remove(enemies,i)
         isAlive = false
     end
   end

   if not isAlive and love.keyboard.isDown('r') then
       -- Remove all bullets and enemies
       enemies = {}
       bullets = {}

       -- Reset Timers
       createEnemyTimer = createEnemyTimerMax
       canShootTimer = canShootTimerMax

       -- Move player back to default position
       player.x = 200
       player.y = 550

       -- Reset the game state (so we can start all over)
       isAlive = true
       score = 0

   end


end

function love.draw()

  -- Draw the plane at the position indicated by the table
  if isAlive then
     love.graphics.draw(player.img, player.x, player.y) -- Draw plane at (100,100); origin point in top-left corner
  else
     love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end

  -- Draw the bullets at the position indicated by the table
  for i,bullet in ipairs(bullets) do
      love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  -- Draw the enemy plane but make sure to rotate 180 degrees from the center (love uses top-left corner as 0,0)
  for i,enemy in ipairs(enemies) do
       love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end

end
