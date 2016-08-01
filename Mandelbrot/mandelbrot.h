
#import <UIKit/UIKit.h>

UIColor* calculateColor(float cr, float ci);

// to do запретить pinc при pan
// доделать rotation
// вынести в другой поток рисование
// оптимизировать рисование перерисовывая только фрагменты

enum palletteScheme { // to do English
    EUnknown,
    EHistogramme, // just number of colors (139) spectrum
    ESmoothRed,
    ESmoothHSV, // smooth hsv
    ESmoothHSV2, // smooth hsv
    EUltra
};

 extern enum palletteScheme curScheme; // to do avoid global


enum palletteScheme toPalette(NSString* name);
NSString* fromPalette(enum palletteScheme palette);

