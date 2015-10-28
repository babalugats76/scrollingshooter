debug = true

-- Timers
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

-- Image storage
bulletImg = love.graphics.newImage('assets/bullet.png')

-- Bullet table
bullets = {} -- used to keep track of the bullets we will shoot

player = { img = nil, x = 200, y = 710, speed = 150 } -- our player table/object

-- Called when the game first starts (load assets, etc.)
function love.load(arg)
   -- Loads the image into memory (assigning to player object)
   player.img = love.graphics.newImage('assets/plane.png')
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

end
-- Called every frame (takes delta time as an argument)
function love.draw()

  -- Draw the plane at the position indicated by the table
  love.graphics.draw(player.img, player.x, player.y) -- Draw plane at (100,100); origin point in top-left corner

  -- Draw the bullets at the position indicated by the table
  for i,bullet in ipairs(bullets) do
      love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end


end
