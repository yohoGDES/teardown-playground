<!-- source: https://teardowngame.com/modding/voxscript.html -->

# Teardown voxscript API (2.0.2)

## Parameters

Parameter outside the init function will show up in the editor 

GetFloat GetBool GetInt GetString GetColor Randomize GetRandomFloat RandomFloat GetRandomInt RandomInt

* * *

## Materials and brushes

Materials can be specific materials created in the script or brushes read from a vox file. Use the Material function to set current material. This material will then be used for all subsequent calls to Box and Sphere. 

CreateMaterial CreateBrush FlipBrush RotateBrush TranslateBrush GetBrushSize Material

* * *

## Images

You can load an image into a voxscript and retrieve dimensions and individual pixel values. This is sometimes useful for instance to create custom heightmaps. 

LoadImage GetImageSize GetImagePixel

* * *

## Shapes

A voxscript must create a Vox shape before anything can be drawn. Each vox shape can have an offset and rotation. Make sure to keep the number of empty voxels in a vox shape as low as possible for better performance. For large, hollow objects, use multiple vox shapes instead. 

Vox Box Sphere Line Set Get Heightmap DebugPrint

* * *

### GetFloat 
    
    
    value, value1, value2, value3 = GetFloat(name, defaultValue, [defaultValue1], [defaultValue2], [defaultValue3])

Arguments  
name (string) - Parameter name  
defaultValue (number) - Default value  
defaultValue1 (number, optional) - Default value  
defaultValue2 (number, optional) - Default value  
defaultValue3 (number, optional) - Default value  


Return value  
value (number) - Parameter value  
value1 (number) - Parameter value  
value2 (number) - Parameter value  
value3 (number) - Parameter value  

    
    
    local r = GetFloat("radius", 5.2)
    
    

* * *

### GetBool 
    
    
    value = GetBool(name, defaultValue)

Arguments  
name (string) - Parameter name  
defaultValue (boolean) - Default value  


Return value  
value (boolean) - Parameter value  

    
    
    --Retrieve playsound parameter, or false if omitted
    local parameterPlaySound = GetBoolParam("playsound", false)
    
    

* * *

### GetInt 
    
    
    value, value1, value2, value3, value4, value5, value6, value7 = GetInt(name, defaultValue, [defaultValue1], [defaultValue2], [defaultValue3], [defaultValue4], [defaultValue5], [defaultValue6], [defaultValue7])

Arguments  
name (string) - Parameter name  
defaultValue (number) - Default value  
defaultValue1 (number, optional) - Default value  
defaultValue2 (number, optional) - Default value  
defaultValue3 (number, optional) - Default value  
defaultValue4 (number, optional) - Default value  
defaultValue5 (number, optional) - Default value  
defaultValue6 (number, optional) - Default value  
defaultValue7 (number, optional) - Default value  


Return value  
value (number) - Parameter value  
value1 (number) - Parameter value  
value2 (number) - Parameter value  
value3 (number) - Parameter value  
value4 (number) - Parameter value  
value5 (number) - Parameter value  
value6 (number) - Parameter value  
value7 (number) - Parameter value  

    
    
    local steps = GetInt("steps", 5)
    
    

* * *

### GetString 
    
    
    value = GetString(name, [defaultValue], [hint])

Arguments  
name (string) - Parameter name  
defaultValue (string, optional) - Default value  
hint (string, optional) - hint  


Return value  
value (string) - Parameter value  

    
    
    local file = GetString("file", "MOD/test.vox")
    
    

* * *

### GetColor 
    
    
    r, g, b, a = GetColor(name, defaultValue, [defaultValue1], [defaultValue2], [defaultValue3])

Arguments  
name (string) - Parameter name  
defaultValue (number) - Default value  
defaultValue1 (number, optional) - Default value  
defaultValue2 (number, optional) - Default value  
defaultValue3 (number, optional) - Default value  


Return value  
r (number) - Parameter value  
g (number) - Parameter value  
b (number) - Parameter value  
a (number) - Parameter value  

    
    
    color_r, color_g, color_b = GetColor("color", 0.39, 0.39, 0.39)
    
    

* * *

### Randomize 
    
    
    Randomize()

Arguments  
() -   


Return value  
none
    
    
    function init()
    	local r = Randomize(5)
    end
    
    

* * *

### GetRandomFloat 
    
    
    value = GetRandomFloat(, )

Arguments  
() -   
() -   


Return value  
value (number) - Returns random floating point number between lower and upper bound  

    
    
    function init()
    	local r = GetRandomFloat(-1.0, 1.0)
    end
    
    

* * *

### RandomFloat 
    
    
    value = RandomFloat(, )

Arguments  
() -   
() -   


Return value  
value (number) - Returns random floating point number between lower and upper bound  


**This function will be deprecated in the next update!**  


* * *

### GetRandomInt 
    
    
    value = GetRandomInt(, )

Arguments  
() -   
() -   


Return value  
value (number) - Returns random integer from lower to (and including) upper bound.  

    
    
    function init()
    	local r = GetRandomInt(1, 3) --Returns 1, 2, or 3
    end
    
    

* * *

### RandomInt 
    
    
    value = RandomInt(, )

Arguments  
() -   
() -   


Return value  
value (number) - Returns random integer from lower to (and including) upper bound.  


**This function will be deprecated in the next update!**  


* * *

### CreateMaterial 
    
    
    material = CreateMaterial(type, r, g, b, [a], [reflect], [shiny], [metal], [emissive])

Arguments  
type (string) - Material type  
r (number) - Red color  
g (number) - Green color  
b (number) - Blue color  
a (number, optional) - Alpha  
reflect (number, optional) - reflectivity  
shiny (number, optional) - Shininess  
metal (number, optional) - Metallic  
emissive (number, optional) - Emissive  


Return value  
material (number) - Material handle  

    
    
    function init()
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    end
    
    

* * *

### CreateBrush 
    
    
    CreateBrush(path, [local])

Arguments  
path (string) - Vox file path and optional object  
local (boolean, optional) - Use local coordinates for all operations. Default false.  


Return value  
none

Create a brush that can be used as material. An objec tin the vox file can be specified using colon (:) delimiter. If a brush uses local coordinates, the brush offset will be relative the current drawn Box or Sphere. Global coordinates will be relative the current Vox origo. 
    
    
    function init()
    	Vox(0,0,0)
    
    	brickWall = CreateBrush("MOD/brickwall.vox")
    	Material(brickWall)
    	Box(0, 0, 0, 10, 10, 10)
    
    	swedishFlag = CreateBrush("MOD/flags.vox:sweden")
    	Material(swedishFlag)
    	Box(0, 0, 0, 20, 15, 1)
    end
    
    

* * *

### FlipBrush 
    
    
    FlipBrush(brush, axes)

Arguments  
brush (number) - Brush handle  
axes (string) - Any combination of x, y and z  


Return value  
none

Apply a flip transformation on the brush 
    
    
    function init()
    	local brush = CreateBrush("brush/white.vox")
    	FlipBrush(brush, "x")
    	Material(brush)
    	Box(0, 0, 0, 20, 15, 5)
    end
    
    

* * *

### RotateBrush 
    
    
    RotateBrush(brush, axis, angle)

Arguments  
brush (number) - Brush handle  
axis (string) - "x", "y" or "z"  
angle (number) - Rotation angle in degrees  


Return value  
none

Apply a rotation transformation on the brush 
    
    
    function init()
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	--Draw box with brush rotated 90 degrees around y axis
    	RotateBrush(brush, "y", 90)
    	Material(brick)
    	Vox(0,0,0)
    	Box(0, 0, 0, 10, 10, 10)
    end
    
    

* * *

### TranslateBrush 
    
    
    TranslateBrush(brush, x, y, z)

Arguments  
brush (number) - Brush handle  
x (number) - Offset along x axis  
y (number) - Offset along y axis  
z (number) - Offset along z axis  


Return value  
none

Apply a translation on the brush 
    
    
    function init()
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	Material(brick)
    	Vox(0,0,0)
    	Box(0, 0, 0, 10, 10, 10)
    	TranslateBrush(brush, 5, 0, 0)
    	Box(0, 0, 0, 10, 10, 10)
    end
    
    

* * *

### GetBrushSize 
    
    
    x, y, z = GetBrushSize(brush)

Arguments  
brush (number) - Brush handle  


Return value  
x (number) - Size along x axis  
y (number) - Size along y axis  
z (number) - Size along z axis  


Return brush size in voxels 
    
    
    function init()
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	Material(brick)
    	Vox(0,0,0)
    	Box(0, 0, 0, 10, 10, 10)
    
    	local xs, ys, zs = GetBrushSize(brush)
    end
    
    
    

* * *

### Material 
    
    
    Material(material)

Arguments  
material (number) - Material or brush handle  


Return value  
none

Set current material or brush. Pass in zero to remove content. 
    
    
    function init()
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	Material(brick)
    	Vox(0,0,0)
    	Box(0, 0, 0, 10, 10, 10)
    
    	--Make box hollow
    	Material(0)
    	Box(2, 2, 2, 8, 8, 8)
    end
    
    

* * *

### LoadImage 
    
    
    LoadImage(path, [grassMapPath])

Arguments  
path (string) - Path to PNG image  
grassMapPath (string, optional) - Path to PNG image  


Return value  
none

Load PNG image from file 
    
    
    function init()
    	LoadImage("MOD/image.png")
    end
    
    

* * *

### GetImageSize 
    
    
    width, height = GetImageSize()

Arguments  
none

Return value  
width (number) - Image width  
height (number) - Image height  


Return image size 
    
    
    function init()
    	LoadImage("MOD/image.png")
    	local w, h = GetImageSize()
    end
    
    

* * *

### GetImagePixel 
    
    
    r, g, b, a = GetImagePixel(x, y)

Arguments  
x (number) - X coordinate  
y (number) - Y coordinate  


Return value  
r (number) - Red  
g (number) - Greeen  
b (number) - Blue  
a (number) - Alpha  


Return color value for image pixel 
    
    
    function init()
    	LoadImage("MOD/image.png")
    	local r,g,b,a = GetImagePixel(50, 50)
    end
    
    

* * *

### Vox 
    
    
    Vox([x], [y], [z], [rx], [ry], [rz], [roundPos])

Arguments  
x (number, optional) - X position  
y (number, optional) - Y position  
z (number, optional) - Z position  
rx (number, optional) - Rotation around X in degrees  
ry (number, optional) - Rotation around Y in degrees  
rz (number, optional) - Rotation around Z in degrees  
roundPos (boolean, optional) - Controls whether to not round the shape position to the local voxel grid. Exists for legacy reasons, default is TRUE  


Return value  
none

Create new shape 
    
    
    function init()
    	--Create vox shape
        Vox(0,0,0)
    
    	--We can now fill it with content
        local brush = CreateBrush("brush/white.vox")
        local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
        Material(brick)
        Box(0, 0, 0, 10, 10, 10)
    end
    
    

* * *

### Box 
    
    
    Box(x0, y0, z0, x1, y1, z1)

Arguments  
x0 (number) - X start  
y0 (number) - Y start  
z0 (number) - Z start  
x1 (number) - X end  
y1 (number) - Y end  
z1 (number) - Z end  


Return value  
none

Draw solid box into the current vox shape using the current material 
    
    
    function init()
        Vox(0,0,0)
        local brush = CreateBrush("brush/white.vox")
        local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
        Material(brick)
        Box(0, 0, 0, 10, 10, 10)
    end
    
    
    

* * *

### Sphere 
    
    
    Sphere(x, y, z, r)

Arguments  
x (number) - X center  
y (number) - Y center  
z (number) - Z center  
r (number) - Radius  


Return value  
none

Draw solid sphere into current vox shape using the current material 
    
    
    function init()
    	Vox(0,0,0)
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	Material(brick)
    	Sphere(0, 0, 0, 15)
    end
    
    

* * *

### Line 
    
    
    Line(xStart, yStart, zStart, xEnd, yEnd, zEnd, thicknessStart, thicknessEnd)

Arguments  
xStart (number) - X start  
yStart (number) - Y start  
zStart (number) - Z start  
xEnd (number) - X end  
yEnd (number) - Y end  
zEnd (number) - Z end  
thicknessStart (number) -   
thicknessEnd (number) -   


Return value  
none

Draw a line from start point to end point 
    
    
    function init()
    	Vox(0,0,0)
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	Material(brick)
    	Line(0, 0, 0, 15)
    end
    
    

* * *

### Set 
    
    
    Set(x, y, z)

Arguments  
x (number) -   
y (number) -   
z (number) -   


Return value  
none

Sets the single voxel in the specified posistion 
    
    
    function init()
    	Vox(0,0,0)
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	Material(brick)
    	Set(0, 0, 0)
    end
    
    

* * *

### Get 
    
    
    material = Get(x, y, z)

Arguments  
x (number) -   
y (number) -   
z (number) -   


Return value  
material (number) -   


Returns the voxel's material id at the specified position 
    
    
    function init()
    	Vox(0,0,0)
    	local brush = CreateBrush("brush/white.vox")
    	local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
    	Material(brick)
    	Set(0, 0, 0)
    	Material(Get(0, 0, 0))
    end
    
    

* * *

### Heightmap 
    
    
    Heightmap(x0, y0, x1, y1, [height], [isNotHollow], [cropBorder])

Arguments  
x0 (number) - X start  
y0 (number) - Y start  
x1 (number) - X end  
y1 (number) - Y end  
height (number, optional) - Height scale  
isNotHollow (boolean, optional) - Unused parameter, for legacy support  
cropBorder (boolean, optional) - Use special handling of borders in heightmap. Reduces amount of voxels and their size  


Return value  
none

Special function to create heightmap based on loaded image into current vox shape Red channel = height Green channel = grass amount Blue channel = special 
    
    
    function init()
        Vox(0,0,0)
        local brush = CreateBrush("brush/white.vox")
        local brick = CreateMaterial("masonry", 0.6, 0.5, 0.3, 0, 0.1, 0, 0)
        Material(brick)
        LoadImage("MOD/heightmap.png")
    	Heightmap(0, 0, 100, 100, 255)
    end
    
    

* * *

### DebugPrint 
    
    
    DebugPrint(message, [lineWrapping])

Arguments  
message (string) - Message to display  
lineWrapping (boolean, optional) - True if you need to wrap Table lines. Works only with tables.  


Return value  
none

Display message on screen. The last 20 lines are displayed. The function will also recognize tables and convert them to strings automatically. 
    
    
    function init()
    	DebugPrint("time")
    
    	local anyTable = {
    		"teardown",
    		{
    			name = "Alex",
    			age = 25,
    			child = { name = "Lena" }
    		},
    		nil,
    		version = "1.6.0",
    		true,
    	}
    	DebugPrint(anyTable)
    end
    
    

* * *
