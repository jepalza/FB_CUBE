' adaptacion del motor grafico 3D CUBE (version 1, la ultima conocida)
' Por JEPALZA, en OCT. 2023 (jepalza arroba gmail punto com)
' derechos de uso de cube segun su propia licencia ZLIB
'
' Cube is freeware, you may use Cube for any purpose as long as you don't blame me for any damages incurred, 
' and you may freely distribute the cube archive unmodified on any media. 
' If you wish to use the cube source code in any way (available from where you got this), 
' even just a mere build, read the readme.txt file carefully (ZLIB license)

	#Inclib "cube"
	
	' si vamos a probar cosas en OPENGL, necesitamos esto
	#Include "fbgfx.bi"
	#Include "sdl/SDL.bi"
	#Include "GL/gl.bi"
	
	dim as integer scr_w=1024, scr_h=768


	Type vec 
		As Single x
		As Single y
	End Type
	
	Type jugador
		As vec o
		As single yaw
	End Type

	Type dynent
	    As vec o, vel                         ' origin, velocity
	    As Single yaw, pitch, roll             ' used as vec in one place
	    As Single maxspeed                     ' cubes per second, 24 for player
	    As BOOL outsidemap                    ' from his eyes
	    As BOOL inwater
	    As BOOL onfloor, jumpnext
	    As Integer move, strafe
	    As BOOL k_left, k_right, k_up, k_down ' see input code  
	    As Integer timeinair                      ' used for fake gravity
	    As Single radius, eyeheight, aboveeye  ' bounding box size
	    As Integer lastupdate, plag, ping
	    As Integer lifesequence                   ' sequence id for each respawn, used in damage test
	    As Integer state                          ' one of CS_* below
	    As Integer frags
	    As Integer health, armour, armourtype, quadmillis
	    As Integer gunselect, gunwait
	    As Integer lastaction, lastattackgun, lastmove
	    As BOOL attacking
	    As Integer ammo(9)
	    As Integer monsterstate                   ' one of M_* below, M_NONE means human
	    As Integer mtype                          ' see monster.cpp
	    As dynent Ptr enemy                      ' monster wants to kill this entity
	    As Single targetyaw                    ' monster wants to look in this direction
	    As BOOL blocked, moving               ' used by physics to signal ai
	    As Integer trigger                        ' millis at which transition to another monsterstate takes place
	    As vec attacktarget                   ' delayed attacks
	    As Integer anger                          ' how many times already hit by fellow monster
	    As string name, team
	End Type
	
	' v=void,osea,sinparametros
	' i=integer
	' f=float
	' Pc=Zstring
	' b=bool
	' dynent= entidad TYPE de jugador
	
	Declare function spawnplayer Cdecl Alias "_Z11spawnplayerP6dynenti"(b As Integer, c As integer) As Integer ptr
	
	Declare Sub changemap Cdecl Alias "_Z9changemapPc"(b As zstring Ptr)
	Declare Sub newmenu Cdecl Alias "_Z7newmenuPc"(b As zstring Ptr)
	Declare Sub execute Cdecl Alias "_Z4execPc"(b As zstring Ptr)
	Declare Sub execfile Cdecl Alias "_Z8execfilePc"(b As zstring Ptr)
	Declare Sub gl_init Cdecl Alias "_Z7gl_initii"(a As Integer,b As integer)
	Declare Sub readdepth Cdecl Alias "_Z9readdepthii"(a As Integer,b As integer)
	Declare Sub empty_world Cdecl Alias "_Z11empty_worldib"(a As Integer,b As BOOL)
	Declare Sub gl_drawframe Cdecl Alias "_Z12gl_drawframeiif"(a As Integer,b As Integer, c As single)
	Declare Sub computeraytable Cdecl Alias "_Z15computeraytableff"(x As Single,y As Single)
	Declare Sub serverslice Cdecl Alias "_Z11serversliceij"(a As integer,c As integer)
	Declare Sub mousemove Cdecl Alias "_Z9mousemoveii"(a As integer,c As integer)
	Declare Sub updateworld Cdecl Alias "_Z11updateworldi"(a As Integer)
	Declare Sub keypress Cdecl Alias "_Z8keypressibi"(a As Integer, b As BOOL, c As integer)
	Declare Sub localconnect Cdecl Alias "_Z12localconnectv"()
	Declare Sub cleardlights Cdecl Alias "_Z12cleardlightsv"()
	Declare Sub initsound Cdecl Alias "_Z9initsoundv"()
	Declare Sub quit Cdecl Alias "_Z4quitv"()


	Declare Sub installtex Cdecl Alias "_Z10installtexiPcRiS0_b"(a As Integer, b As zstring Ptr, xs As Integer ptr, ys As Integer ptr, clamp As BOOL=FALSE)
	Declare Function newstring Cdecl Alias "_Z9newstringPc"(b As zstring Ptr) As ZString Ptr 
	Declare Function path Cdecl Alias "_Z4pathPc"(b As zstring Ptr) As ZString Ptr 
	
	Declare sub conoutf Cdecl Alias "_Z7conoutfPKcz"(b As zstring Ptr, ...)

	Dim As String mapa=Command
	If mapa="" Then mapa="metl3"

	SDL_Init(SDL_INIT_TIMER Or SDL_INIT_VIDEO)
		
	empty_world(7, TRUE)
	
	SDL_InitSubSystem(SDL_INIT_VIDEO)
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
	SDL_SetVideoMode(scr_w, scr_h, 0, SDL_OPENGL)' Or SDL_FULLSCREEN)
   SDL_WM_SetCaption("cube engine", NULL)
   SDL_WM_GrabInput(SDL_GRAB_ON)
   
   'keyrepeat(false)
   Dim As Integer si=0
   SDL_EnableKeyRepeat(IIf(si , SDL_DEFAULT_REPEAT_DELAY , 0) , SDL_DEFAULT_REPEAT_INTERVAL)
   
   SDL_ShowCursor(0)
   
   gl_init(scr_w, scr_h)

   Dim As integer xs, ys
   'Print *path(newstring("data/newchars.png"))
   'Print *newstring("data/newchars.png"):sleep
   installtex(2, path(newstring("data/newchars.png")), @xs, @ys)
   installtex(3, path(newstring("data/martin/base.png")), @xs, @ys)
   installtex(6, path(newstring("data/martin/ball1.png")), @xs, @ys)
   installtex(7, path(newstring("data/martin/smoke.png")), @xs, @ys)
   installtex(8, path(newstring("data/martin/ball2.png")), @xs, @ys)
   installtex(9, path(newstring("data/martin/ball3.png")), @xs, @ys)
   installtex(4, path(newstring("data/explosion.jpg")), @xs, @ys)
   installtex(5, path(newstring("data/items.png")), @xs, @ys)
   installtex(1, path(newstring("data/crosshair.png")), @xs, @ys)
   
   initsound()
   
    newmenu("frags\tpj\tping\tteam\tname")
    newmenu("ping\tplr\tserver")
    execute("data/keymap.cfg")
    execute("data/menus.cfg")
    execute("data/prefabs.cfg")
    execute("data/sounds.cfg")
    execute("servers.cfg")
    execfile("config.cfg") 'por defecto si no existe . execfile("data/defaults.cfg")
    execute("autoexec.cfg") 

	localconnect()
	changemap(mapa)
	
	Dim As Integer gamespeed=30
	Dim As Integer lastmillis=SDL_GetTicks()*gamespeed/30
	Dim As Integer minmillis=5

	Dim As integer framesinmap = 0
	Dim As integer ignoremouse = 5
	Dim As integer curtime = 10

	Dim As dynent Ptr player1
	
	While 1
		Dim As integer millis = SDL_GetTicks()*gamespeed/30
        
		If(millis-lastmillis>200) Then
			lastmillis = millis-200
		ElseIf(millis-lastmillis<1) Then 
			lastmillis = millis-1
		EndIf
		  
      If(millis-lastmillis<minmillis) Then
			SDL_Delay(minmillis-(millis-lastmillis))
      EndIf

		cleardlights()
      updateworld(millis)
      
		serverslice(Int(Timer), 0)
			  
		player1=spawnplayer(NULL,1)	  
			  
      Static As Single fps=30
      fps = (1000.0f/curtime+fps*50)/51
      computeraytable(player1->o.x, player1->o.y)
      'conoutf("pepe: %f,%f", player1.x, player1.y)
     
		readdepth(scr_w, scr_h)
		
		curtime=millis-lastmillis
		
		SDL_GL_SwapBuffers()
		
		If(framesinmap<5) Then
			player1->yaw += 5
			gl_drawframe(scr_w, scr_h, fps)
			player1->yaw -= 5
		EndIf
		framesinmap+=1
		gl_drawframe(scr_w, scr_h, fps)


		  Dim as SDL_Event evento
		  dim as integer lasttype = 0, lastbut = 0
        while(SDL_PollEvent(@evento))
            Select case (evento.type)
            
                case SDL_QUIT_
                    quit()

                Case SDL_KEYDOWN,SDL_KEYUP
                    keypress(evento.key.keysym.sym, evento.key.state=SDL_PRESSED, evento.key.keysym.sym)
                    
                case SDL_MOUSEMOTION
                    if (ignoremouse) then ignoremouse-=1 : exit select
                    mousemove(evento.motion.xrel, evento.motion.yrel)
                    
                case SDL_MOUSEBUTTONDOWN,SDL_MOUSEBUTTONUP
                    If (lasttype=evento.type) andalso (lastbut=evento.button.button) Then Exit Select
                    keypress(-evento.button.button, evento.button.state<>0, 0)
                    lasttype = evento.Type
                    lastbut = evento.button.button
                    
            end select
        Wend


	Wend	
	