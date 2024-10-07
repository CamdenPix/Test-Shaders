#version 330 compatibility
#define ROOT 3
#define KERNEL_SIZE (ROOT*ROOT)

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	
	vec2 texOffset = 1.0 / vec2(textureSize(colortex0, 0));
    //Generate kernel offsets dynamically
    vec2 offsets[KERNEL_SIZE];
    for(int y = 0; y < ROOT; y++){
        for(int x = 0; x < ROOT; x++){
            //Fills in Top-Left to Bottom-Right, or at least it should; it's Midnight and I'm distracting myself with a stream
            offsets[y*ROOT+x] = vec2(texOffset.x*float(x-ROOT/2),texOffset.y*float(-y+ROOT/2));
        }
    }

    vec3 sampleTex[KERNEL_SIZE];
    for(int i = 0; i < KERNEL_SIZE; i++){
        vec3 pixel = texture(colortex0, texcoord + offsets[i]).rgb;
        sampleTex[i] = pixel;
    }


    //Sobel Filter Code
	float horizontal_kernel[9] = float[](
    	-47.0,-168.0,-47.0,
     	 0.0, 0.0, 0.0,
     	 47.0, 168.0, 47.0
	);

    float vertical_kernel[9] = float[](
    	-47.0, 0.0, 47.0,
     	-168.0, 0.0, 168.0,
     	-47.0, 0.0, 47.0
	);
    
	vec3 resultColorX = vec3(0.0);
    for (int i = 0; i < 9; i++) {
        resultColorX += sampleTex[i] * horizontal_kernel[i];
    }
    vec3 resultColorY = vec3(0.0);
    for (int i = 0; i < 9; i++) {
        resultColorY += sampleTex[i] * vertical_kernel[i];
    }
    vec3 resultColor = vec3(0.0);
    resultColor.r = sqrt(resultColorX.r*resultColorX.r + resultColorY.r * resultColorY.r);
    resultColor.g = sqrt(resultColorX.g*resultColorX.g + resultColorY.g * resultColorY.g);
    resultColor.b = sqrt(resultColorX.b*resultColorX.b + resultColorY.b * resultColorY.b);

	color = vec4(resultColor, 1.0);
}