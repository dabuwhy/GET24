shader_type canvas_item;
uniform float cutoff:hint_range(0.0, 1.0, 0.1)=0.5;
uniform float feather:hint_range(0.0, 1.0, 0.1)=0.2;
uniform sampler2D mask;
void fragment() {
	// Place fragment code here.
	vec4 col=vec4(0,0,0.3,1.0);
//	if(UV.x<cutoff-feather){
//		col.a=0.0;
//	}else if(UV.x<cutoff){
//		col.a=(UV.x-(cutoff-feather))/feather;
//	}
	col.a=smoothstep(cutoff-feather,cutoff,(1.0-UV.x)*(1.0-feather));
	COLOR=col;
}
