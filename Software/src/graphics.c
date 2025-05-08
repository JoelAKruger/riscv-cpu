float sinf(float arg);
float atan2f(float y, float x);
float sqrtf(float arg);

typedef struct
{
    float X, Y;
} v2;

typedef struct
{
    float R, G, B;
} v3;

static float
Length(v2 Vec)
{
    return sqrtf(Vec.X * Vec.X + Vec.Y * Vec.Y);
}

static float
Clamp(float Value, float Min, float Max)
{
    float Result = Value;
    if (Result < Min) Result = Min;
    if (Result > Max) Result = Max;
    return Result;
}

static float
Spiral(v2 M, float T)
{
    float R = Length(M);
	float A = atan2f(M.Y, M.X);
	float V = sinf(100.0f*(sqrtf(R)-0.02*A-0.3*T));
	return Clamp(V,0.0f,1.0f);
}

static v3
Shader(float T, float U, float V)
{
    v2 M = {0.5f, 0.5f};
    float Value = Spiral((v2){M.X - U, M.Y - V}, T);
    return (v3){Value, Value, Value};
}

static void
RunShader(screen_buffer Output)
{
    float T = 0.0f;
    for(;;)
    {
        for (int Y = 0; Y < Output.Height; Y++)
        {
            for (int X = 0; X < Output.Width; X++)
            {
                float U = (float)X / Output.Width;
                float V = (float)Y / Output.Height;
                
                v3 Result = Shader(T, U, V);
                int R = (int)(Result.R * 7) & 0x7;
                int G = (int)(Result.G * 7) & 0x7;
                int B = (int)(Result.B * 3) & 0x3;
                
                u8 Color = (R << 5) | (G << 2) | B;
                SetPixel(Output, X, Y, Color);
            }
        }
        
        T += 0.05f;
    }
}