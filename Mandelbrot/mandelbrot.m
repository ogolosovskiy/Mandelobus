
#import "mandelbrot.h"


struct RGB
{
    int R;
    int G;
    int B;
};

struct RGB palette[139] = {
    {233,150,122}, {250,128,114}, {255,160,122}, {255,69,0}, {255,140,0}, {255,165,0}, {255,215,0}, {184,134,11},
    {218,165,32}, {238,232,170}, {189,183,107}, {240,230,140}, {128,128,0}, {255,255,0}, {154,205,50}, {85,107,47},
    {107,142,35}, {124,252,0}, {127,255,0}, {173,255,47}, {0,100,0}, {0,128,0}, {34,139,34}, {0,255,0}, {50,205,50},
    {144,238,144}, {152,251,152}, {143,188,143}, {0,250,154}, {0,255,127}, {46,139,87}, {102,205,170}, {60,179,113},
    {32,178,170}, {47,79,79}, {0,128,128}, {0,139,139}, {0,255,255}, {0,255,255}, {224,255,255}, {0,206,209}, {64,224,208},
    {72,209,204}, {175,238,238}, {127,255,212}, {176,224,230}, {95,158,160}, {70,130,180}, {100,149,237}, {0,191,255},
    {30,144,255}, {173,216,230}, {135,206,235}, {135,206,250}, {25,25,112}, {0,0,128}, {0,0,139}, {0,0,205}, {0,0,255},
    {65,105,225}, {138,43,226}, {75,0,130}, {72,61,139}, {106,90,205}, {123,104,238}, {147,112,219}, {139,0,139},
    {148,0,211}, {153,50,204}, {186,85,211}, {128,0,128}, {216,191,216}, {221,160,221}, {238,130,238}, {255,0,255},
    {218,112,214}, {199,21,133}, {219,112,147}, {255,20,147}, {255,105,180}, {255,182,193}, {255,192,203}, {250,235,215},
    {245,245,220}, {255,228,196}, {255,235,205}, {245,222,179}, {255,248,220}, {255,250,205}, {250,250,210}, {255,255,224},
    {139,69,19}, {160,82,45}, {210,105,30}, {205,133,63}, {244,164,96}, {222,184,135}, {210,180,140}, {188,143,143},
    {255,228,181}, {255,222,173}, {255,218,185}, {255,228,225}, {255,240,245}, {250,240,230}, {253,245,230}, {255,239,213},
    {255,245,238}, {245,255,250}, {112,128,144}, {119,136,153}, {176,196,222}, {230,230,250}, {255,250,240}, {240,248,255},
    {248,248,255}, {240,255,240}, {255,255,240}, {240,255,255}, {255,250,250}, {0,0,0}, {105,105,105}, {128,128,128},
    {169,169,169}, {192,192,192}, {211,211,211}, {220,220,220}, {245,245,245}, {255,255,255}
};

struct RGB UltraFractal[16] = {
    {66, 30, 15}, {25, 7, 26}, {9, 1, 47}, {4, 4, 73}, {0, 7, 100}, {12, 44, 138}, {24, 82, 177}, {57, 125, 209},
    {134, 181, 229}, {211, 236, 248}, {241, 233, 191}, {248, 201, 95}, {255, 170, 0}, {204, 128, 0}, {153, 87, 0}, {106, 52, 3} };


enum palletteScheme { // to do English
    EHistigramm, // just number of colors (139) spectrum
    ESmoothRed,
    ESmoothHSV, // smooth hsv
    ESmoothHSV2, // smooth hsv
    EUltra
} curScheme = EUltra;

#if curScheme == EUltra
const int max_it = 255;
#elif curScheme == ESmoothRed
const int max_it = 255;
#else
const int max_it = 4096;
#endif

void step_clr(float* red, float* green, float* blue)
{
    int step = (max_it*3)/max_it;
    *red = (int)(*red + step) < max_it ? *red + step : max_it;
    if((int)*red == 0xff)
        *green = (int)(*green + step) < max_it ? *green + step : max_it;
    if((int)*green == 0xff)
        *blue = (int)(*blue + step) < max_it ? *blue + step : max_it;
}

int Clamp(int i)
{
    if (i < 0) return 0;
    if (i > 255) return 255;
    return i;
}

void HsvToRgb(float h, float S, float V, int* red, int* green, int* blue)
{
    float H = h;
    while (H < 0) { H += 360; };
    while (H >= 360) { H -= 360; };
    float R, G, B;
    if (V <= 0)
    { R = G = B = 0; }
    else if (S <= 0)
    {
        R = G = B = V;
    }
    else
    {
        float hf = H / 60.0;
        int i = floor(hf);
        float f = hf - i;
        float pv = V * (1 - S);
        float qv = V * (1 - S * f);
        float tv = V * (1 - S * (1 - f));
        switch (i)
        {
                
                // Red is the dominant color
                
            case 0:
                R = V;
                G = tv;
                B = pv;
                break;
                
                // Green is the dominant color
                
            case 1:
                R = qv;
                G = V;
                B = pv;
                break;
            case 2:
                R = pv;
                G = V;
                B = tv;
                break;
                
                // Blue is the dominant color
                
            case 3:
                R = pv;
                G = qv;
                B = V;
                break;
            case 4:
                R = tv;
                G = pv;
                B = V;
                break;
                
                // Red is the dominant color
                
            case 5:
                R = V;
                G = pv;
                B = qv;
                break;
                
                // Just in case we overshoot on our math by a little, we put these here. Since its a switch it won't slow us down at all to put these here.
                
            case 6:
                R = V;
                G = tv;
                B = pv;
                break;
            case -1:
                R = V;
                G = pv;
                B = qv;
                break;
                
                // The color is not defined, we should throw an error.
                
            default:
                //LFATAL("i Value error in Pixel conversion, Value is %d", i);
                R = G = B = V; // Just pretend its black/white
                break;
        }
    }
    
    *red = Clamp((int)(R * 255.0));
    *green = Clamp((int)(G * 255.0));
    *blue = Clamp((int)(B * 255.0));
}



UIColor* smoothHSVcolor(int i, float r, float c)
{
    float di= i;
    float zn;
    float hue;
    
    zn = sqrt(r + c);
    hue = di + 1.0 - log(log(fabsf(zn))) / log(2.0);  // 2 is escape radius
    hue = 0.95 + 20.0 * hue; // adjust to make it prettier
    // the hsv function expects values from 0 to 360
    while (hue > 360.0)
        hue -= 360.0;
    while (hue < 0.0)
        hue += 360.0;
    
    int red = 0;
    int green = 0;
    int blue = 0;
    HsvToRgb(hue, 0.8, 1.0, &red, &green, &blue);
    
    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:1.0f];
}


UIColor* calculateColor(float cr, float ci) {

    
    float zr = 0.0, zi = 0.0;
    int IterationsPerPixel = 0;
    const int infinity_sqr = 16;
    
    float red = 0, green = 0, blue = 0;
    
    while( IterationsPerPixel < max_it && zr*zr + zi*zi < infinity_sqr)
    {
        IterationsPerPixel++;
        float temp = zr*zr - zi*zi + cr;
        zi = 2*zr*zi + ci;
        zr = temp;
        if(curScheme == ESmoothRed)
            step_clr(&red, &green, &blue);
    }

    // to do switch
    if(curScheme == EUltra)
    {
        struct RGB rgb = {0,0,0};
        if (IterationsPerPixel < max_it) {
            rgb = UltraFractal[IterationsPerPixel % 16];
        }
        return [UIColor colorWithRed:rgb.R/255.0f
                               green:rgb.G/255.0f
                                blue:rgb.B/255.0f
                               alpha:1.0f];
    }
    else
    if(curScheme== ESmoothHSV2)
    {
        float zn = sqrt(zr*zr + zi*zi);
        float nsmooth = IterationsPerPixel + 1 - log(log(fabsf(zn)))/log(2);
        
        int rgb_red = 0;
        int rgb_green = 0;
        int rgb_blue = 0;
        HsvToRgb(.95f + 10 * nsmooth ,0.6f,1.0f, &rgb_red, &rgb_green, &rgb_blue);
        
        return [UIColor colorWithRed:rgb_red/255.0f
                               green:rgb_green/255.0f
                                blue:rgb_blue/255.0f
                               alpha:1.0f];
        
    }
    else
    if(curScheme== ESmoothHSV)
    {
        return smoothHSVcolor(IterationsPerPixel, zr*zr, zi*zi);
    }
    else
    if(curScheme==EHistigramm)
    {
        size_t pal_sz = sizeof(palette)/sizeof(palette[0]);
        struct RGB col = palette[IterationsPerPixel%pal_sz];
        return [UIColor colorWithRed:col.R/255.0f
                               green:col.G/255.0f
                                blue:col.B/255.0f
                               alpha:1.0f];
        
    }
    else
    if(curScheme==ESmoothRed)
    {
        if(IterationsPerPixel == max_it)
        {
            return [UIColor blackColor];
        }
        else
            return [UIColor colorWithRed : red/255.0f
                                   green : green/255.0f
                                    blue : blue/255.0f
                                   alpha : 1.0f];
    }
    else
        return [UIColor blackColor];
}

    


