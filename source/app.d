import adjustxml;

import std.stdio;
import std.file;
import std.conv;
import std.range;
import std.algorithm;
import std.string;
import core.thread;

//import opengl.gl;
//import opengl.glu;
//import opengl.glfw;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

import collada.collada;
import collada.model;

//static XMLDocument doc = parseXML( import("multimtl_triangulate.dae") );

GLFWwindow* g_Window = null;

extern (System)
{
void KeyFunc( GLFWwindow* window, int key, int scancode, int action, int mods ){ 
	writeln( "call keycallbackfunc" );
	writeln( key, " ", action );
	
	switch( key )
	{
		case GLFW_KEY_LEFT :
		{
			if( glfwGetKey( window, GLFW_KEY_LSHIFT ) )
				glTranslatef( -1.0, 0.0, 0.0 );
			else
				glRotatef( 3.0f, 0.0, 1.0, 0.0 );
		} break;
		
		case GLFW_KEY_RIGHT :
		{
			if( glfwGetKey( window, GLFW_KEY_LSHIFT ) )
				glTranslatef( 1.0, 0.0, 0.0 );
			else
				glRotatef( -3.0f, 0.0, 1.0, 0.0 );
		} break;
		
		case GLFW_KEY_UP :
		{
			if( glfwGetKey( window, GLFW_KEY_LSHIFT ) )
				glTranslatef( 0.0, -1.0, 0.0 );
			else
				glRotatef( 3.0f, 1.0, 0.0, 0.0 );
		} break;
		
		case GLFW_KEY_DOWN :
		{
			if( glfwGetKey( window, GLFW_KEY_LSHIFT ) )
				glTranslatef( 0.0, 1.0, 0.0 );
			else
				glRotatef( -3.0f, 1.0, 0.0, 0.0 );
		} break;
		
		default : {} break;
	}
} 

void CharFunc( GLFWwindow* window, uint codepoinr ) { 
	//writeln( "call charFunc" );
	//writeln( character, " ", action );
} 

void MouseButtonFunc( GLFWwindow* window, int button, int action, int mods ) { 
	//writeln( "call ButtonFunc" );
	//writeln( button, " ", action );
} 

void CursorPosFunc( GLFWwindow* window, double xpos, double ypos ) { 
	//writeln( "call MousePosFunc" );
	//writeln( x, " ", y );
} 

static int wpos = 0;
static int cscale = 0;
void ScrollFunc( GLFWwindow* window, double xoffset, double yoffset ) { 
	writeln( "call MouseWheelFunc" );
	writefln( "xoffset = %s, yoffset = %s", xoffset, yoffset );
/+	
	if( pos > wpos )
	{
		cscale = min( cscale+1, 10 );
		
	}
	else if( pos < wpos )
	{
		cscale = max( cscale-1, -10 );
	}
+/	
/+
	if( pos > wpos )
	{
		if( ( -10 <= cscale ) && ( cscale < 0 ) )
		{
			glPopMatrix();
			cscale++;
		}
		else if( ( 0 <= cscale ) && ( cscale < 10 ) )
		{
			glPushMatrix();
			glScalef( 1.1, 1.1, 1.1 );
			cscale = min( cscale+1, 10 );
		}
	}
	else if( pos < wpos )
	{
		if( ( -10 < cscale ) && ( cscale <= 0 ) )
		{
			glPushMatrix();
			glScalef( 0.9, 0.9, 0.9 );
			cscale = max( cscale-1, -10 );
		}
		else if( ( 0 < cscale ) && ( cscale <= 10 ) )
		{
			glPopMatrix();
			cscale--;
		}
	}
	else
	{
	
	}
	
	wpos = pos;
+/
} 

void WindowSizeFunc( GLFWwindow* window, int width, int height ) { 
	//writeln( "call WindowSizeFunc" );
	//writeln( width, " ", height );
} 

void WindowCloseFunc( GLFWwindow* window ) { 
	//writeln( "call WindowCloseFunc" );
} 

void WindowRefreshFunc( GLFWwindow* window ) { 
	//writeln( "call WindowRefreshFunc" );
} 
}

void main( string[] args )
{
    writeln("gl load...");
    DerelictGL.load();

    writeln("glfw load...");
    DerelictGLFW3.load();
	
    writeln("glfw initialize...");
	if( !glfwInit() )
	{
		writeln("Initialize faild.");
		return;
	}
	scope(exit)
    {
        writeln("glfw terminate...");
        glfwTerminate();
    }
    
	//if( !glfwOpenWindow( 0, 0, 0, 0, 0, 0, 8, 0, GLFW_WINDOW ) )
	//{
	//	writeln("Open window faild.");
	//	return;
	//}
    

    writeln("open new window...");
    g_Window = glfwCreateWindow( 640, 480, "test".toStringz, null, null );

    if( !g_Window )
    {
        writeln("Open window failed.");
        return;
    }
    scope(exit) {
        writeln("window close...");
        glfwDestroyWindow( g_Window );
    }

	glfwSetKeyCallback( g_Window, &KeyFunc ); 
	glfwSetCharCallback( g_Window, &CharFunc ); 
	glfwSetMouseButtonCallback( g_Window, &MouseButtonFunc ); 
	glfwSetCursorPosCallback( g_Window, &CursorPosFunc ); 
	glfwSetScrollCallback( g_Window, &ScrollFunc ); 

	glfwSetWindowSizeCallback( g_Window, &WindowSizeFunc ); 
	glfwSetWindowCloseCallback( g_Window, &WindowCloseFunc ); 
	glfwSetWindowRefreshCallback( g_Window, &WindowRefreshFunc ); 
	
	writeln("il load...");
	DerelictIL.load();

    writeln("il initialize...");
	ilInit();
	
	writeln("ilu load...");
	DerelictILU.load();

    writeln("ilu initialize...");
	iluInit();

	XMLDocument doc = parseXML( import("AppearanceMikuA.dae") );
	
	Collada collada = new Collada;
	collada.load( doc.root );
	
	auto model = ColladaModel( collada, "/Users/hayato/Programming/D/project/ColladaLoader/AppearanceMiku" );

	//glMatrixMode( GL_PROJECTION );
	//glLoadIdentity;	
	//gluPerspective( 37.8493, 1.0, 10.0, 1000.0 );
	//gluLookAt( 0.0,10.0,30.0, 0.0,0.0,0.0, 0.0,1.0,0.0 );
	
	//float[4] pos = [0.0, 0.0, 10.0, 0.0];
	//glLightfv(GL_LIGHT0, GL_POSITION, pos.ptr);
	//glEnable(GL_LIGHTING);
	//glEnable(GL_LIGHT0);

	double prevTime = glfwGetTime();
	int count = 0;
	
	//glMatrixMode( GL_MODELVIEW );

    writeln("start main loop.");
	
    //while( glfwGetWindowAttrib( g_Window, GLFW_FOCUSED ) )
    while( !glfwWindowShouldClose( g_Window ) )
	{
		count++;
		if( glfwGetTime() - prevTime > 1.0 )
		{
			glfwSetWindowTitle( g_Window, count.to!string.toStringz );
            prevTime = glfwGetTime();
			count = 0;
		}
/+		
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		glEnable(GL_DEPTH_TEST);
/+		
		glLineWidth( 2 );
		
		glPushMatrix();
		//x red
		glColor3f( 1, 0, 0 );
		glBegin( GL_LINES );
			glVertex3f(  10.0, 0.0, 0.0 );
			glVertex3f( -10.0, 0.0, 0.0 );
		glEnd();
		//y green
		glColor3f( 0, 1, 0 );
		glBegin( GL_LINES );
			glVertex3f( 0.0,  10.0, 0.0 );
			glVertex3f( 0.0, -10.0, 0.0 );
		glEnd();
		//z blue
		glColor3f( 0, 0, 1 );
		glBegin( GL_LINES );
			glVertex3f( 0.0, 0.0,  10.0 );
			glVertex3f( 0.0, 0.0, -10.0 );
		glEnd();
		glPopMatrix();
		
		glColor3f( 1, 1, 1 );
		glLineWidth( 1 );
+/
		if( glfwGetKey( g_Window, 84/+t+/ ) )
			model.enableTexture = !(model.enableTexture);
		
		if( glfwGetKey( g_Window, 66/+b+/ ) )
			model.enableBone = !(model.enableBone);

        if( glfwGetKey( g_Window,  83/+s+/ ) )
		{
            model.selectAnimation( 0 );
			model.move();
			//model.draw();
            //model.drawBone();
			model.suspend();
			Thread.sleep( dur!("msecs")( 100 ) ); //0.5 sec
		}

        if( glfwGetKey( g_Window, 79/+o+/ ) )
            model.suspend();

        if( glfwGetKey( g_Window, 80/+p+/ ) )
            model.resume();

        if( glfwGetKey( g_Window, 72/+h+/ ) )
            model.moveStep( Step.PREV, 0.001 );

        if( glfwGetKey( g_Window, 76/+l+/ ) )
            model.moveStep( Step.NEXT, 0.001 );
	    
        model.move();
		model.draw();
        model.drawBone();
		
		glDisable(GL_DEPTH_TEST);
+/		
		glfwSwapBuffers( g_Window );
        glfwPollEvents();
	}
	
	return;
}
