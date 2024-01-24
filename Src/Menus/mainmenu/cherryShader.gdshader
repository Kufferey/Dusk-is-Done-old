shader_type spatial;

void vertex() {
	VERTEX.x += sin(TIME * 1.0 + VERTEX.x + 5.0) * 0.5;
	VERTEX.y += sin(TIME * 1.0 + VERTEX.y + 5.0) * 0.5;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
