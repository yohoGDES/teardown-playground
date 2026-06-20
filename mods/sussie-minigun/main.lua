-- Sussie Minigun
-- Fires explosive Among Us crewmates at rapid-fire rate.
-- Uses the stock Teardown minigun 3D model as the weapon body.
-- Select the tool (slot 6), hold left-click to fire.

#version 2
#include "script/include/player.lua"

------------------------------------------------------------------------
-- Config
------------------------------------------------------------------------

local FIRE_RATE       = 0.03   -- seconds between shots (~33/sec)
local BULLET_SPEED    = 70     -- meters per second
local BULLET_MAX_DIST = 150    -- despawn distance (meters)
local SPREAD          = 0.03   -- cone spread
local EXPLODE_RADIUS  = 0.7    -- soft-material destruction radius
local EXPLODE_SHAKE   = 0.15   -- camera shake strength
local MAX_PROJECTILES = 40     -- cap active sussies to avoid perf issues
local IMPACT_LINGER   = 0.4    -- seconds a sussie vox lingers at impact

-- Sussie color (red crewmate trail tint)
local SR, SG, SB = 0.9, 0.1, 0.1

------------------------------------------------------------------------
-- Shared state (server writes, client reads)
------------------------------------------------------------------------
-- shared.projectiles  — list of {pos, dir, dist} for in-flight sussies (raycast tracked)
-- shared.impacts      — list of {pos} for explosions this frame
-- shared.impactBodies — list of {body, timer} for lingering sussie vox at impact sites

------------------------------------------------------------------------
-- SERVER
------------------------------------------------------------------------

function server.init()
    RegisterTool("sussie_minigun", "Sussie Minigun", "MOD/prefab/minigun.xml", 6)
    shared.projectiles  = {}
    shared.impacts      = {}
    shared.impactBodies = {}
    shared.fireTimer    = 0
end

function client.init()
    SetToolAllowedZoom("sussie_minigun", false)
end

function server.tick(dt)
    shared.fireTimer = shared.fireTimer - dt
    shared.impacts   = {}

    for p in PlayersAdded() do
        SetToolEnabled("sussie_minigun", true, p)
        SetToolAmmo("sussie_minigun", 999, p)
    end

    for p in Players() do
        if GetPlayerTool(p) == "sussie_minigun" and
           InputDown("usetool", p) and
           shared.fireTimer <= 0 then
            shared.fireTimer = FIRE_RATE
            spawnSussie(p)
        end
    end

    updateProjectiles(dt)
    updateImpactBodies(dt)
end

function spawnSussie(p)
    local projs = shared.projectiles
    if #projs >= MAX_PROJECTILES then return end

    local mt = GetToolLocationWorldTransform("muzzle", p)
    if mt == nil then return end

    local _, _, _, dir = GetPlayerAimInfo(mt.pos, BULLET_MAX_DIST, p)
    dir = VecNormalize(Vec(
        dir[1] + (math.random() - 0.5) * SPREAD,
        dir[2] + (math.random() - 0.5) * SPREAD,
        dir[3] + (math.random() - 0.5) * SPREAD
    ))

    local origin = VecAdd(mt.pos, VecScale(dir, 0.3))
    projs[#projs + 1] = {pos = origin, dir = dir, dist = 0}
    shared.projectiles = projs
end

function updateProjectiles(dt)
    local projs   = shared.projectiles
    local impacts = shared.impacts
    local ibs     = shared.impactBodies
    local keep    = {}

    for _, p in ipairs(projs) do
        local step = BULLET_SPEED * dt
        local hit, dist = QueryRaycast(p.pos, p.dir, step + 0.2)

        if hit then
            local impactPos = VecAdd(p.pos, VecScale(p.dir, dist))
            MakeHole(impactPos, EXPLODE_RADIUS, EXPLODE_RADIUS * 0.4)
            impacts[#impacts + 1] = {pos = impactPos}
            -- Spawn a sussie vox at impact that lingers briefly then disappears
            local handles = Spawn("MOD/prefab/sussie.xml", Transform(impactPos))
            for i = 1, #handles do
                local b = GetShapeBody(handles[i])
                if b ~= nil then
                    SetBodyDynamic(b, false)
                    ibs[#ibs + 1] = {body = b, timer = IMPACT_LINGER}
                    break
                end
            end
        else
            p.pos  = VecAdd(p.pos, VecScale(p.dir, step))
            p.dist = p.dist + step
            if p.dist <= BULLET_MAX_DIST then
                keep[#keep + 1] = p
            end
        end
    end

    shared.projectiles  = keep
    shared.impacts      = impacts
    shared.impactBodies = ibs
end

function updateImpactBodies(dt)
    local ibs  = shared.impactBodies
    local keep = {}
    for _, ib in ipairs(ibs) do
        ib.timer = ib.timer - dt
        if ib.timer <= 0 then
            if IsHandleValid(ib.body) then Delete(ib.body) end
        else
            keep[#keep + 1] = ib
        end
    end
    shared.impactBodies = keep
end

------------------------------------------------------------------------
-- CLIENT
------------------------------------------------------------------------

function client.tick(dt)
    -- Explosion camera shake
    for _, impact in ipairs(shared.impacts or {}) do
        ShakeCamera(EXPLODE_SHAKE)
    end

    -- In-flight sussie particle trails
    ParticleReset()
    ParticleType("plain")
    ParticleColor(SR, SG, SB, SR * 0.4, SG * 0.1, SB * 0.1)
    ParticleRadius(0.12, 0.04)
    ParticleGravity(0)
    for _, p in ipairs(shared.projectiles or {}) do
        SpawnParticle(p.pos, Vec(0, 0, 0), 0.15)
    end

    -- Explosion burst particles
    for _, impact in ipairs(shared.impacts or {}) do
        ParticleReset()
        ParticleType("plain")
        ParticleColor(1.0, 0.3, 0.0, 0.8, 0.1, 0.0)
        ParticleRadius(0.35, 0.15)
        ParticleGravity(-3)
        for i = 1, 14 do
            SpawnParticle(impact.pos, Vec(
                (math.random() - 0.5) * 10,
                math.random() * 8 + 2,
                (math.random() - 0.5) * 10
            ), 0.7)
        end
        ParticleReset()
        ParticleType("smoke")
        ParticleColor(SR, SG, SB, SR * 0.3, SG * 0.05, SB * 0.05)
        ParticleRadius(0.5, 0.2)
        ParticleGravity(-5)
        for i = 1, 6 do
            SpawnParticle(impact.pos, Vec(
                (math.random() - 0.5) * 4,
                math.random() * 5 + 3,
                (math.random() - 0.5) * 4
            ), 0.8)
        end
    end
end

function client.draw()
    -- HUD crosshair
    UiTranslate(UiCenter(), UiMiddle())
    UiColor(1, 1, 1, 0.7)
    UiPush()
        UiTranslate(-6, -1)
        UiRect(12, 2)
    UiPop()
    UiPush()
        UiTranslate(-1, -6)
        UiRect(2, 12)
    UiPop()

    -- Sussie counter
    local count = #(shared.projectiles or {})
    if count > 0 then
        UiTranslate(UiCenter() - 80, UiMiddle() + 24)
        UiFont("bold.ttf", 18)
        UiColor(SR, SG, SB, 1)
        UiText("SUSSIES IN FLIGHT: " .. count)
    end
end
