-- Sussie Minigun
-- Shoots explosive Among Us crewmates (sussies) at a rapid fire rate.
-- Left-click to fire. Sussies explode on contact with anything.
--
-- PHASE 1: Projectiles are represented as colored particle trails.
--
-- PHASE 2 (vox art): When you have a sussie .vox file, drop it in:
--   mods/sussie-minigun/assets/sussie.vox
-- Then uncomment the Spawn() block in spawnSussie() below and remove
-- the particle-trail fallback. The sussie will appear as a physical
-- vox object flying through the air before it explodes.
--
-- NOTE: Teardown 2.0 API splits callbacks into server.* and client.*
--   server.*  = game logic, physics, MakeHole, projectile movement
--   client.*  = camera, UI, particles, ShakeCamera
-- We use shared{} to pass data between the two halves.

------------------------------------------------------------------------
-- Config
------------------------------------------------------------------------

local FIRE_RATE       = 0.06   -- seconds between shots (~16/sec)
local BULLET_SPEED    = 70     -- meters per second
local BULLET_MAX_DIST = 150    -- despawn after this far (meters)
local SPREAD          = 0.025  -- cone spread (0 = perfectly accurate)
local EXPLODE_RADIUS  = 1.8    -- soft-material destruction radius
local EXPLODE_SHAKE   = 0.5    -- camera shake strength

-- Sussie color (purple crewmate)
local SR, SG, SB = 0.45, 0.2, 0.9

------------------------------------------------------------------------
-- Shared state (server writes, client reads)
------------------------------------------------------------------------
-- shared.projectiles  — list of {pos, dir, dist} for in-flight sussies
-- shared.impacts      — list of {pos} for explosions this frame (client draws them)

------------------------------------------------------------------------
-- SERVER — game logic
------------------------------------------------------------------------

function server.init()
    shared.projectiles = {}
    shared.impacts     = {}
    -- Phase 2: no preloading needed server-side for vox spawning
end

function server.tick(dt)
    -- fireTimer lives in shared so client can read it (not strictly needed,
    -- but keeps all mutable state in one place)
    shared.fireTimer = (shared.fireTimer or 0) - dt
    shared.impacts   = {}  -- reset impact list each frame

    if InputDown("lmb") and shared.fireTimer <= 0 then
        shared.fireTimer = FIRE_RATE
        spawnSussie()
    end

    updateProjectiles(dt)
end

function spawnSussie()
    -- InputDown is server-side; we read the camera transform via shared
    -- (set by client each tick — see client.tick below)
    local cam = shared.camTransform
    if cam == nil then return end

    local forward = TransformToParentVec(cam, Vec(0, 0, -1))
    local dir = Vec(
        forward[1] + (math.random() - 0.5) * SPREAD,
        forward[2] + (math.random() - 0.5) * SPREAD,
        forward[3] + (math.random() - 0.5) * SPREAD
    )
    dir = VecNormalize(dir)

    -- Spawn a little ahead of camera so it doesn't self-collide
    local origin = VecAdd(cam.pos, VecScale(dir, 1.2))

    -- ----------------------------------------------------------------
    -- PHASE 2 — uncomment once you have sussie.vox
    -- ----------------------------------------------------------------
    -- local t = Transform(origin, cam.rot)
    -- local body = Spawn("MOD/assets/sussie.vox", t, true)
    -- if IsHandleValid(body) then
    --     SetBodyVelocity(body, VecScale(dir, BULLET_SPEED))
    -- end
    -- ----------------------------------------------------------------

    local projs = shared.projectiles
    projs[#projs + 1] = {pos = origin, dir = dir, dist = 0}
    shared.projectiles = projs
end

function updateProjectiles(dt)
    local projs   = shared.projectiles
    local impacts = shared.impacts
    local keep    = {}

    for _, p in ipairs(projs) do
        local step = BULLET_SPEED * dt
        local hit, dist = QueryRaycast(p.pos, p.dir, step + 0.2)

        if hit then
            local impactPos = VecAdd(p.pos, VecScale(p.dir, dist))
            -- Blow a hole (server-only API call)
            MakeHole(impactPos, EXPLODE_RADIUS, EXPLODE_RADIUS * 0.4)
            -- Tell client to draw the explosion particles
            impacts[#impacts + 1] = {pos = impactPos}
        else
            p.pos  = VecAdd(p.pos, VecScale(p.dir, step))
            p.dist = p.dist + step
            if p.dist <= BULLET_MAX_DIST then
                keep[#keep + 1] = p
            end
        end
    end

    shared.projectiles = keep
    shared.impacts     = impacts
end

------------------------------------------------------------------------
-- CLIENT — camera, particles, UI
------------------------------------------------------------------------

function client.tick(dt)
    -- Share camera transform with server so it can aim shots
    shared.camTransform = GetCameraTransform()

    -- Shake camera for each explosion this frame
    for _, impact in ipairs(shared.impacts or {}) do
        ShakeCamera(EXPLODE_SHAKE)
    end
end

function client.draw()
    -- In-flight sussie particle trails
    ParticleReset()
    ParticleType("plain")
    ParticleColor(SR, SG, SB, SR * 0.4, SG * 0.4, SB * 0.4)
    ParticleRadius(0.12, 0.04)
    ParticleGravity(0)
    for _, p in ipairs(shared.projectiles or {}) do
        SpawnParticle(p.pos, Vec(0, 0, 0), 0.15)
    end

    -- Explosion particles for each impact this frame
    for _, impact in ipairs(shared.impacts or {}) do
        -- Orange burst
        ParticleReset()
        ParticleType("plain")
        ParticleColor(1.0, 0.5, 0.0, 0.8, 0.2, 0.0)
        ParticleRadius(0.35, 0.15)
        ParticleGravity(-3)
        for i = 1, 14 do
            local vel = Vec(
                (math.random() - 0.5) * 10,
                math.random() * 8 + 2,
                (math.random() - 0.5) * 10
            )
            SpawnParticle(impact.pos, vel, 0.7)
        end
        -- Purple sussie soul puff
        ParticleReset()
        ParticleType("smoke")
        ParticleColor(SR, SG, SB, SR * 0.3, SG * 0.1, SB * 0.4)
        ParticleRadius(0.5, 0.2)
        ParticleGravity(-5)
        for i = 1, 6 do
            local vel = Vec(
                (math.random() - 0.5) * 4,
                math.random() * 5 + 3,
                (math.random() - 0.5) * 4
            )
            SpawnParticle(impact.pos, vel, 0.8)
        end
    end

    -- HUD crosshair
    UiTranslate(UiCenter(), UiMiddle())
    UiColor(1, 1, 1, 0.7)
    UiPush()
        UiTranslate(-6, -1)
        UiRect(12, 2)   -- horizontal bar
    UiPop()
    UiPush()
        UiTranslate(-1, -6)
        UiRect(2, 12)   -- vertical bar
    UiPop()

    -- Sussie counter
    UiTranslate(UiCenter() - 80, UiMiddle() + 24)
    UiFont("bold.ttf", 18)
    UiColor(SR, SG, SB, 1)
    local count = #(shared.projectiles or {})
    UiText(count > 0 and ("SUSSIES IN FLIGHT: " .. count) or "")
end
