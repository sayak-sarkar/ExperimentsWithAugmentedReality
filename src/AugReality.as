package {
	//imported classes (automatically generated)
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.BitmapFileMaterial;
	
	//This SWF command generates the size, framerate and color of the window
	[SWF(width="640", height="480", frameRate="30", backgroundColor="#FFFFFF")]
	
	public class AugReality extends Sprite
	{
		//Embed the "marker.pat" template into the project
		[Embed(source="marker.pat", mimeType="application/octet-stream")]
		private var marker:Class;
		
		//Embed the "camera_para.dat" webcam data file into the project
		[Embed(source="camera_para.dat", mimeType="application/octet-stream")]
		private var cam_params:Class;
		
		//createFLAR variables
		private var ar_params:FLARParam;
		private var ar_marker:FLARCode;
		//createCam variables
		private var ar_vid:Video;
		private var ar_cam:Camera;
		//createBMP vairiables
		private var ar_bmp:BitmapData;
		private var ar_raster:FLARRgbRaster_BitmapData;
		private var ar_detection:FLARSingleMarkerDetector;
		//createPapervision variables
		private var ar_scene:Scene3D;
		private var ar_3dcam:FLARCamera3D;
		private var ar_basenode:FLARBaseNode;
		private var ar_viewport:Viewport3D;
		private var ar_renderengine:BasicRenderEngine;
		private var ar_transmat:FLARTransMatResult;
		private var ar_cube:Cube

		//This function is automatically generated		
		public function AugReality()
		{
			void createFLAR();//call the createFlar function
			void createCam();//call the createCam function
			void createBMP();//call the createBMP function
			void createPapervision();//call the createPapervision function
			addEventListener(Event.ENTER_FRAME, loop);//call the loop event
		}
		//This function sets up the FLAR marker file and webcam settings
		public function createFLAR()
		{
			ar_params = new FLARParam();//create new paramaters for the project
			ar_marker = new FLARCode(16, 16);//create a new 16x16 marker for the project
			ar_params.loadARParam(new cam_params() as ByteArray);//loads paramaters for the webcam
			ar_marker.loadARPatt(new marker());//loads the marker file template
		}
		//This function sets up a new camera that will project the images
		public function createCam()
		{
			ar_vid = new Video(640, 480);//video settings match the SWF size (above)
			ar_cam = Camera.getCamera(); //make a new project camera
			ar_cam.setMode(640, 480, 30);//camera setings match the video and SWF settings
			ar_vid.attachCamera(ar_cam);//attach the camera to the video
			addChild(ar_vid);//attach the video to the project
		}
		//This function sets up a new Bitmap canvas
		public function createBMP()
		{
			ar_bmp = new BitmapData(640, 480);//create a new Bitmap canvas to match the size of the project
			ar_bmp.draw(ar_vid);//draw the Bitmap canvas onto the video
			ar_raster = new FLARRgbRaster_BitmapData(ar_bmp);//Rasterize the Bitmap to RGB
			ar_detection = new FLARSingleMarkerDetector(ar_params, ar_marker, 80);//Attach the marker file as the detection point
		}
		//This function creates a new PaperVision 3D object
		public function createPapervision()
		{
			ar_scene = new Scene3D();//Create a new scene
			ar_3dcam = new FLARCamera3D(ar_params);//Create a new 3D camera
			ar_basenode = new FLARBaseNode();//Create a new content box
			ar_renderengine = new BasicRenderEngine();//Create a new rendering object
			ar_transmat = new FLARTransMatResult();//Create a new transformation matrix
			ar_viewport = new Viewport3D();//Create a new viewport
			
			//The code below creates a light that adds shadow to the 3D object
			var ar_light:PointLight3D = new PointLight3D();//Create a new light variable
			ar_light.x = 1000;//X axis position for the light
			ar_light.y = 1000;//Y axis position for the light
			ar_light.z = -1000;//Z axis position for the light
			
			//The code below attaches an image file to the Papervision object
			var ar_bitmap:BitmapFileMaterial;//Create a new material file
			ar_bitmap = new BitmapFileMaterial("object.gif");//Attach an image to the material
			ar_bitmap.doubleSided = true;//Cover front and back of planes
			
			//create a new cube object that is 80x80x80 pixels
			ar_cube = new Cube(new MaterialsList({all:ar_bitmap}), 80, 80, 80);
									
			ar_scene.addChild(ar_basenode);//add the content box to the scene
			ar_basenode.addChild(ar_cube);// add the cube to the content box (remove if using a DAE)
			addChild(ar_viewport);//Add the viewport to the project
		}
		
		//This loop tells the project what to do when the video loads
		private function loop(e:Event):void
		{
			ar_bmp.draw(ar_vid);//attach the bitmap to the webcam video
			ar_cube.rotationX +=4;//rotate the cube 4 pixels per frame on the X axis
			ar_cube.rotationY +=6;//rotate the cube 6 pixels per frame on the Y axis
			
			try //This "try" clause catches any errors and prevents them from locking up the program.
			{
				//The below code detects the marker "if" it is in the viewing area
				if(ar_detection.detectMarkerLite(ar_raster, 80) && ar_detection.getConfidence() > 0.5)
				{
					ar_detection.getTransformMatrix(ar_transmat);//When the marker is found, get the transformation matrix
					ar_basenode.setTransformMatrix(ar_transmat);//Place the content box onto the transformatin matrix
					ar_renderengine.renderScene(ar_scene, ar_3dcam, ar_viewport);//Render the scene
				}
			}
			catch(e:Error){}//catch any errors
		}
	}
}