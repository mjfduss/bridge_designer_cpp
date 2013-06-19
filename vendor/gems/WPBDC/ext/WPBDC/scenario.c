#include "stdafx.h"
#include "internal.h"

// Scenario descriptors

// Note the index values are used in the hash function, so don't
// fiddle with the indices between main contest and semi-finals.
// The indices do _not_ have to be in order.

// Lookup table is sorted on 10-char ID field for binary search.
// The search routine will bubble the semifinal row to the right location.
static TScenarioDescriptor scenario_descriptor_tbl[] = {
    { 999, SEMIFINAL_SCENARIO_ID, "99Z", 100000.00 },
    {   0, "1050824100", "27A",  99874.40 },
    {   1, "1051220100", "32A", 105140.00 },
    {   2, "1051616100", "36A", 111994.40 },
    {   3, "1052012100", "39A", 116437.60 },
    {   4, "1052408100", "41A", 122469.60 },
    {   5, "1052804100", "42A", 127090.40 },
    {   6, "1053200000", "07A", 132250.00 },
    {   7, "1053200031", "70A", 136750.00 },
    {   8, "1053200200", "14A", 138250.00 },
    {   9, "1053200300", "21A", 144250.00 },
    {  10, "1053200331", "98A", 148750.00 },
    {  11, "1060820100", "26A",  95590.00 },
    {  12, "1061216100", "31A", 101444.40 },
    {  13, "1061612100", "35A", 108887.60 },
    {  14, "1062008100", "38A", 113919.60 },
    {  15, "1062404100", "40A", 120540.40 },
    {  16, "1062804000", "06A", 123100.00 },
    {  17, "1062804040", "68A", 126600.00 },
    {  18, "1062804041", "69A", 128600.00 },
    {  19, "1062804200", "13A", 129100.00 },
    {  20, "1062804300", "20A", 135100.00 },
    {  21, "1062804340", "96A", 138600.00 },
    {  22, "1062804341", "97A", 140600.00 },
    {  23, "1070816100", "25A",  91894.40 },
    {  24, "1071212100", "30A",  98337.60 },
    {  25, "1071608100", "34A", 106369.60 },
    {  26, "1072004100", "37A", 111990.40 },
    {  27, "1072404040", "66A", 119950.00 },
    {  28, "1072404340", "94A", 131950.00 },
    {  29, "1072408000", "05A", 113950.00 },
    {  30, "1072408040", "65A", 117950.00 },
    {  31, "1072408041", "67A", 121950.00 },
    {  32, "1072408200", "12A", 119950.00 },
    {  33, "1072408300", "19A", 125950.00 },
    {  34, "1072408340", "93A", 129950.00 },
    {  35, "1072408341", "95A", 133950.00 },
    {  36, "1080812100", "24A",  88787.60 },
    {  37, "1081208100", "29A",  95819.60 },
    {  38, "1081604100", "33A", 104440.40 },
    {  39, "1082004050", "63A", 109800.00 },
    {  40, "1082004350", "91A", 121800.00 },
    {  41, "1082008050", "62A", 107800.00 },
    {  42, "1082008350", "90A", 119800.00 },
    {  43, "1082012000", "04A", 102800.00 },
    {  44, "1082012050", "61A", 105800.00 },
    {  45, "1082012051", "64A", 111800.00 },
    {  46, "1082012200", "11A", 108800.00 },
    {  47, "1082012300", "18A", 114800.00 },
    {  48, "1082012350", "89A", 117800.00 },
    {  49, "1082012351", "92A", 123800.00 },
    {  50, "1090808100", "23A",  86269.60 },
    {  51, "1091204100", "28A",  93890.40 },
    {  52, "1091604050", "59A", 102150.00 },
    {  53, "1091604350", "87A", 114150.00 },
    {  54, "1091608050", "58A", 100150.00 },
    {  55, "1091608350", "86A", 112150.00 },
    {  56, "1091612050", "57A",  98150.00 },
    {  57, "1091612350", "85A", 110150.00 },
    {  58, "1091616000", "03A",  92650.00 },
    {  59, "1091616050", "56A",  96150.00 },
    {  60, "1091616051", "60A", 104150.00 },
    {  61, "1091616200", "10A",  98650.00 },
    {  62, "1091616300", "17A", 104650.00 },
    {  63, "1091616350", "84A", 108150.00 },
    {  64, "1091616351", "88A", 116150.00 },
    {  65, "1100804100", "22A",  84340.40 },
    {  66, "1101204060", "54A",  90000.00 },
    {  67, "1101204360", "82A", 102000.00 },
    {  68, "1101208060", "53A",  88000.00 },
    {  69, "1101208360", "81A", 100000.00 },
    {  70, "1101212060", "52A",  86000.00 },
    {  71, "1101212360", "80A",  98000.00 },
    {  72, "1101216060", "51A",  84000.00 },
    {  73, "1101216360", "79A",  96000.00 },
    {  74, "1101220000", "02A",  79500.00 },
    {  75, "1101220060", "50A",  82000.00 },
    {  76, "1101220061", "55A",  92000.00 },
    {  77, "1101220200", "09A",  85500.00 },
    {  78, "1101220300", "16A",  91500.00 },
    {  79, "1101220360", "78A",  94000.00 },
    {  80, "1101220361", "83A", 104000.00 },
    {  81, "1110804060", "48A",  80350.00 },
    {  82, "1110804360", "76A",  92350.00 },
    {  83, "1110808060", "47A",  78350.00 },
    {  84, "1110808360", "75A",  90350.00 },
    {  85, "1110812060", "46A",  76350.00 },
    {  86, "1110812360", "74A",  88350.00 },
    {  87, "1110816060", "45A",  74350.00 },
    {  88, "1110816360", "73A",  86350.00 },
    {  89, "1110820060", "44A",  72350.00 },
    {  90, "1110820360", "72A",  84350.00 },
    {  91, "1110824000", "01A",  67350.00 },
    {  92, "1110824060", "43A",  70350.00 },
    {  93, "1110824061", "49A",  82350.00 },
    {  94, "1110824200", "08A",  73350.00 },
    {  95, "1110824300", "15A",  79350.00 },
    {  96, "1110824360", "71A",  82350.00 },
    {  97, "1110824361", "77A",  94350.00 },
    {  98, "2050824100", "27B",  99874.40 },
    {  99, "2051220100", "32B", 105140.00 },
    { 100, "2051616100", "36B", 111994.40 },
    { 101, "2052012100", "39B", 116437.60 },
    { 102, "2052408100", "41B", 122469.60 },
    { 103, "2052804100", "42B", 127090.40 },
    { 104, "2053200000", "07B", 132250.00 },
    { 105, "2053200031", "70B", 136750.00 },
    { 106, "2053200200", "14B", 138250.00 },
    { 107, "2053200300", "21B", 144250.00 },
    { 108, "2053200331", "98B", 148750.00 },
    { 109, "2060820100", "26B",  95590.00 },
    { 110, "2061216100", "31B", 101444.40 },
    { 111, "2061612100", "35B", 108887.60 },
    { 112, "2062008100", "38B", 113919.60 },
    { 113, "2062404100", "40B", 120540.40 },
    { 114, "2062804000", "06B", 123100.00 },
    { 115, "2062804040", "68B", 126600.00 },
    { 116, "2062804041", "69B", 128600.00 },
    { 117, "2062804200", "13B", 129100.00 },
    { 118, "2062804300", "20B", 135100.00 },
    { 119, "2062804340", "96B", 138600.00 },
    { 120, "2062804341", "97B", 140600.00 },
    { 121, "2070816100", "25B",  91894.40 },
    { 122, "2071212100", "30B",  98337.60 },
    { 123, "2071608100", "34B", 106369.60 },
    { 124, "2072004100", "37B", 111990.40 },
    { 125, "2072404040", "66B", 119950.00 },
    { 126, "2072404340", "94B", 131950.00 },
    { 127, "2072408000", "05B", 113950.00 },
    { 128, "2072408040", "65B", 117950.00 },
    { 129, "2072408041", "67B", 121950.00 },
    { 130, "2072408200", "12B", 119950.00 },
    { 131, "2072408300", "19B", 125950.00 },
    { 132, "2072408340", "93B", 129950.00 },
    { 133, "2072408341", "95B", 133950.00 },
    { 134, "2080812100", "24B",  88787.60 },
    { 135, "2081208100", "29B",  95819.60 },
    { 136, "2081604100", "33B", 104440.40 },
    { 137, "2082004050", "63B", 109800.00 },
    { 138, "2082004350", "91B", 121800.00 },
    { 139, "2082008050", "62B", 107800.00 },
    { 140, "2082008350", "90B", 119800.00 },
    { 141, "2082012000", "04B", 102800.00 },
    { 142, "2082012050", "61B", 105800.00 },
    { 143, "2082012051", "64B", 111800.00 },
    { 144, "2082012200", "11B", 108800.00 },
    { 145, "2082012300", "18B", 114800.00 },
    { 146, "2082012350", "89B", 117800.00 },
    { 147, "2082012351", "92B", 123800.00 },
    { 148, "2090808100", "23B",  86269.60 },
    { 149, "2091204100", "28B",  93890.40 },
    { 150, "2091604050", "59B", 102150.00 },
    { 151, "2091604350", "87B", 114150.00 },
    { 152, "2091608050", "58B", 100150.00 },
    { 153, "2091608350", "86B", 112150.00 },
    { 154, "2091612050", "57B",  98150.00 },
    { 155, "2091612350", "85B", 110150.00 },
    { 156, "2091616000", "03B",  92650.00 },
    { 157, "2091616050", "56B",  96150.00 },
    { 158, "2091616051", "60B", 104150.00 },
    { 159, "2091616200", "10B",  98650.00 },
    { 160, "2091616300", "17B", 104650.00 },
    { 161, "2091616350", "84B", 108150.00 },
    { 162, "2091616351", "88B", 116150.00 },
    { 163, "2100804100", "22B",  84340.40 },
    { 164, "2101204060", "54B",  90000.00 },
    { 165, "2101204360", "82B", 102000.00 },
    { 166, "2101208060", "53B",  88000.00 },
    { 167, "2101208360", "81B", 100000.00 },
    { 168, "2101212060", "52B",  86000.00 },
    { 169, "2101212360", "80B",  98000.00 },
    { 170, "2101216060", "51B",  84000.00 },
    { 171, "2101216360", "79B",  96000.00 },
    { 172, "2101220000", "02B",  79500.00 },
    { 173, "2101220060", "50B",  82000.00 },
    { 174, "2101220061", "55B",  92000.00 },
    { 175, "2101220200", "09B",  85500.00 },
    { 176, "2101220300", "16B",  91500.00 },
    { 177, "2101220360", "78B",  94000.00 },
    { 178, "2101220361", "83B", 104000.00 },
    { 179, "2110804060", "48B",  80350.00 },
    { 180, "2110804360", "76B",  92350.00 },
    { 181, "2110808060", "47B",  78350.00 },
    { 182, "2110808360", "75B",  90350.00 },
    { 183, "2110812060", "46B",  76350.00 },
    { 184, "2110812360", "74B",  88350.00 },
    { 185, "2110816060", "45B",  74350.00 },
    { 186, "2110816360", "73B",  86350.00 },
    { 187, "2110820060", "44B",  72350.00 },
    { 188, "2110820360", "72B",  84350.00 },
    { 189, "2110824000", "01B",  67350.00 },
    { 190, "2110824060", "43B",  70350.00 },
    { 191, "2110824061", "49B",  82350.00 },
    { 192, "2110824200", "08B",  73350.00 },
    { 193, "2110824300", "15B",  79350.00 },
    { 194, "2110824360", "71B",  82350.00 },
    { 195, "2110824361", "77B",  94350.00 },
    { 196, "3050824100", "27C", 102124.40 },
    { 197, "3051220100", "32C", 107390.00 },
    { 198, "3051616100", "36C", 114244.40 },
    { 199, "3052012100", "39C", 118687.60 },
    { 200, "3052408100", "41C", 124719.60 },
    { 201, "3052804100", "42C", 129340.40 },
    { 202, "3053200000", "07C", 134500.00 },
    { 203, "3053200031", "70C", 139000.00 },
    { 204, "3053200200", "14C", 140500.00 },
    { 205, "3053200300", "21C", 146500.00 },
    { 206, "3053200331", "98C", 151000.00 },
    { 207, "3060820100", "26C",  98290.00 },
    { 208, "3061216100", "31C", 104144.40 },
    { 209, "3061612100", "35C", 111587.60 },
    { 210, "3062008100", "38C", 116619.60 },
    { 211, "3062404100", "40C", 123240.40 },
    { 212, "3062804000", "06C", 125800.00 },
    { 213, "3062804040", "68C", 129300.00 },
    { 214, "3062804041", "69C", 131300.00 },
    { 215, "3062804200", "13C", 131800.00 },
    { 216, "3062804300", "20C", 137800.00 },
    { 217, "3062804340", "96C", 141300.00 },
    { 218, "3062804341", "97C", 143300.00 },
    { 219, "3070816100", "25C",  95044.40 },
    { 220, "3071212100", "30C", 101487.60 },
    { 221, "3071608100", "34C", 109519.60 },
    { 222, "3072004100", "37C", 115140.40 },
    { 223, "3072404040", "66C", 123100.00 },
    { 224, "3072404340", "94C", 135100.00 },
    { 225, "3072408000", "05C", 117100.00 },
    { 226, "3072408040", "65C", 121100.00 },
    { 227, "3072408041", "67C", 125100.00 },
    { 228, "3072408200", "12C", 123100.00 },
    { 229, "3072408300", "19C", 129100.00 },
    { 230, "3072408340", "93C", 133100.00 },
    { 231, "3072408341", "95C", 137100.00 },
    { 232, "3080812100", "24C",  92387.60 },
    { 233, "3081208100", "29C",  99419.60 },
    { 234, "3081604100", "33C", 108040.40 },
    { 235, "3082004050", "63C", 113400.00 },
    { 236, "3082004350", "91C", 125400.00 },
    { 237, "3082008050", "62C", 111400.00 },
    { 238, "3082008350", "90C", 123400.00 },
    { 239, "3082012000", "04C", 106400.00 },
    { 240, "3082012050", "61C", 109400.00 },
    { 241, "3082012051", "64C", 115400.00 },
    { 242, "3082012200", "11C", 112400.00 },
    { 243, "3082012300", "18C", 118400.00 },
    { 244, "3082012350", "89C", 121400.00 },
    { 245, "3082012351", "92C", 127400.00 },
    { 246, "3090808100", "23C",  90319.60 },
    { 247, "3091204100", "28C",  97940.40 },
    { 248, "3091604050", "59C", 106200.00 },
    { 249, "3091604350", "87C", 118200.00 },
    { 250, "3091608050", "58C", 104200.00 },
    { 251, "3091608350", "86C", 116200.00 },
    { 252, "3091612050", "57C", 102200.00 },
    { 253, "3091612350", "85C", 114200.00 },
    { 254, "3091616000", "03C",  96700.00 },
    { 255, "3091616050", "56C", 100200.00 },
    { 256, "3091616051", "60C", 108200.00 },
    { 257, "3091616200", "10C", 102700.00 },
    { 258, "3091616300", "17C", 108700.00 },
    { 259, "3091616350", "84C", 112200.00 },
    { 260, "3091616351", "88C", 120200.00 },
    { 261, "3100804100", "22C",  88840.40 },
    { 262, "3101204060", "54C",  94500.00 },
    { 263, "3101204360", "82C", 106500.00 },
    { 264, "3101208060", "53C",  92500.00 },
    { 265, "3101208360", "81C", 104500.00 },
    { 266, "3101212060", "52C",  90500.00 },
    { 267, "3101212360", "80C", 102500.00 },
    { 268, "3101216060", "51C",  88500.00 },
    { 269, "3101216360", "79C", 100500.00 },
    { 270, "3101220000", "02C",  84000.00 },
    { 271, "3101220060", "50C",  86500.00 },
    { 272, "3101220061", "55C",  96500.00 },
    { 273, "3101220200", "09C",  90000.00 },
    { 274, "3101220300", "16C",  96000.00 },
    { 275, "3101220360", "78C",  98500.00 },
    { 276, "3101220361", "83C", 108500.00 },
    { 277, "3110804060", "48C",  85300.00 },
    { 278, "3110804360", "76C",  97300.00 },
    { 279, "3110808060", "47C",  83300.00 },
    { 280, "3110808360", "75C",  95300.00 },
    { 281, "3110812060", "46C",  81300.00 },
    { 282, "3110812360", "74C",  93300.00 },
    { 283, "3110816060", "45C",  79300.00 },
    { 284, "3110816360", "73C",  91300.00 },
    { 285, "3110820060", "44C",  77300.00 },
    { 286, "3110820360", "72C",  89300.00 },
    { 287, "3110824000", "01C",  72300.00 },
    { 288, "3110824060", "43C",  75300.00 },
    { 289, "3110824061", "49C",  87300.00 },
    { 290, "3110824200", "08C",  78300.00 },
    { 291, "3110824300", "15C",  84300.00 },
    { 292, "3110824360", "71C",  87300.00 },
    { 293, "3110824361", "77C",  99300.00 },
    { 294, "4050824100", "27D", 102124.40 },
    { 295, "4051220100", "32D", 107390.00 },
    { 296, "4051616100", "36D", 114244.40 },
    { 297, "4052012100", "39D", 118687.60 },
    { 298, "4052408100", "41D", 124719.60 },
    { 299, "4052804100", "42D", 129340.40 },
    { 300, "4053200000", "07D", 134500.00 },
    { 301, "4053200031", "70D", 139000.00 },
    { 302, "4053200200", "14D", 140500.00 },
    { 303, "4053200300", "21D", 146500.00 },
    { 304, "4053200331", "98D", 151000.00 },
    { 305, "4060820100", "26D",  98290.00 },
    { 306, "4061216100", "31D", 104144.40 },
    { 307, "4061612100", "35D", 111587.60 },
    { 308, "4062008100", "38D", 116619.60 },
    { 309, "4062404100", "40D", 123240.40 },
    { 310, "4062804000", "06D", 125800.00 },
    { 311, "4062804040", "68D", 129300.00 },
    { 312, "4062804041", "69D", 131300.00 },
    { 313, "4062804200", "13D", 131800.00 },
    { 314, "4062804300", "20D", 137800.00 },
    { 315, "4062804340", "96D", 141300.00 },
    { 316, "4062804341", "97D", 143300.00 },
    { 317, "4070816100", "25D",  95044.40 },
    { 318, "4071212100", "30D", 101487.60 },
    { 319, "4071608100", "34D", 109519.60 },
    { 320, "4072004100", "37D", 115140.40 },
    { 321, "4072404040", "66D", 123100.00 },
    { 322, "4072404340", "94D", 135100.00 },
    { 323, "4072408000", "05D", 117100.00 },
    { 324, "4072408040", "65D", 121100.00 },
    { 325, "4072408041", "67D", 125100.00 },
    { 326, "4072408200", "12D", 123100.00 },
    { 327, "4072408300", "19D", 129100.00 },
    { 328, "4072408340", "93D", 133100.00 },
    { 329, "4072408341", "95D", 137100.00 },
    { 330, "4080812100", "24D",  92387.60 },
    { 331, "4081208100", "29D",  99419.60 },
    { 332, "4081604100", "33D", 108040.40 },
    { 333, "4082004050", "63D", 113400.00 },
    { 334, "4082004350", "91D", 125400.00 },
    { 335, "4082008050", "62D", 111400.00 },
    { 336, "4082008350", "90D", 123400.00 },
    { 337, "4082012000", "04D", 106400.00 },
    { 338, "4082012050", "61D", 109400.00 },
    { 339, "4082012051", "64D", 115400.00 },
    { 340, "4082012200", "11D", 112400.00 },
    { 341, "4082012300", "18D", 118400.00 },
    { 342, "4082012350", "89D", 121400.00 },
    { 343, "4082012351", "92D", 127400.00 },
    { 344, "4090808100", "23D",  90319.60 },
    { 345, "4091204100", "28D",  97940.40 },
    { 346, "4091604050", "59D", 106200.00 },
    { 347, "4091604350", "87D", 118200.00 },
    { 348, "4091608050", "58D", 104200.00 },
    { 349, "4091608350", "86D", 116200.00 },
    { 350, "4091612050", "57D", 102200.00 },
    { 351, "4091612350", "85D", 114200.00 },
    { 352, "4091616000", "03D",  96700.00 },
    { 353, "4091616050", "56D", 100200.00 },
    { 354, "4091616051", "60D", 108200.00 },
    { 355, "4091616200", "10D", 102700.00 },
    { 356, "4091616300", "17D", 108700.00 },
    { 357, "4091616350", "84D", 112200.00 },
    { 358, "4091616351", "88D", 120200.00 },
    { 359, "4100804100", "22D",  88840.40 },
    { 360, "4101204060", "54D",  94500.00 },
    { 361, "4101204360", "82D", 106500.00 },
    { 362, "4101208060", "53D",  92500.00 },
    { 363, "4101208360", "81D", 104500.00 },
    { 364, "4101212060", "52D",  90500.00 },
    { 365, "4101212360", "80D", 102500.00 },
    { 366, "4101216060", "51D",  88500.00 },
    { 367, "4101216360", "79D", 100500.00 },
    { 368, "4101220000", "02D",  84000.00 },
    { 369, "4101220060", "50D",  86500.00 },
    { 370, "4101220061", "55D",  96500.00 },
    { 371, "4101220200", "09D",  90000.00 },
    { 372, "4101220300", "16D",  96000.00 },
    { 373, "4101220360", "78D",  98500.00 },
    { 374, "4101220361", "83D", 108500.00 },
    { 375, "4110804060", "48D",  85300.00 },
    { 376, "4110804360", "76D",  97300.00 },
    { 377, "4110808060", "47D",  83300.00 },
    { 378, "4110808360", "75D",  95300.00 },
    { 379, "4110812060", "46D",  81300.00 },
    { 380, "4110812360", "74D",  93300.00 },
    { 381, "4110816060", "45D",  79300.00 },
    { 382, "4110816360", "73D",  91300.00 },
    { 383, "4110820060", "44D",  77300.00 },
    { 384, "4110820360", "72D",  89300.00 },
    { 385, "4110824000", "01D",  72300.00 },
    { 386, "4110824060", "43D",  75300.00 },
    { 387, "4110824061", "49D",  87300.00 },
    { 388, "4110824200", "08D",  78300.00 },
    { 389, "4110824300", "15D",  84300.00 },
    { 390, "4110824360", "71D",  87300.00 },
    { 391, "4110824361", "77D",  99300.00 },
};

static int to_upper_case(int c)
{
  return ('a' <= c && c <= 'z') ? c + ('A' - 'a') : c;
}

static TBool scenario_numbers_equal(char *a, char *b)
{
  return a[0] == b[0] && a[1] == b[1] && to_upper_case(a[2]) == to_upper_case(b[2]);
}

// Input must be a string of length at least 3.
char *local_contest_number_to_id(char *number)
{
	unsigned i;

	for (i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl); i++)
	    if (scenario_numbers_equal(scenario_descriptor_tbl[i].number, number))
			return scenario_descriptor_tbl[i].id;
	return NULL;
}

int lookup_scenario_descriptor(TScenarioDescriptor *desc, char *id)
{
	static TScenarioDescriptor null_desc = NULL_SCENARIO_DESCRIPTOR;
	static int initialized_p = 0;
	int lo = 0;
	int hi = STATIC_ARRAY_SIZE(scenario_descriptor_tbl) - 1;
	int i, cmp, mid;

    // Bubble the semifinal scenario to the right position one time.
    if (!initialized_p) {
        initialized_p = 1;
        TScenarioDescriptor semifinal_descriptor = scenario_descriptor_tbl[0];
        for (i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl) - 1; i++) {
            if (strncmp(scenario_descriptor_tbl[i + 1].id, semifinal_descriptor.id, SCENARIO_ID_SIZE) < 0)
                scenario_descriptor_tbl[i] = scenario_descriptor_tbl[i + 1];
            else
                break;
        }
        scenario_descriptor_tbl[i] = semifinal_descriptor;
    }

    // Don't bother searching for the null semifinal scenario.
    if (strncmp(id, NULL_SEMIFINAL_SCENARIO_ID, SCENARIO_ID_SIZE) != 0) {

        while (lo <= hi) {
            mid = (unsigned)(lo + hi) >> 1;
            cmp = strncmp(id, scenario_descriptor_tbl[mid].id, SCENARIO_ID_SIZE);
            if (cmp < 0)
                hi = mid - 1;
            else if (cmp > 0)
                lo = mid + 1;
            else {
                if (desc)
                    *desc = scenario_descriptor_tbl[mid];
                return mid;
            }
        }

    }
	if (desc)
		*desc = null_desc;
	return -1;
}

// Load scenarios

// Set contents of a load scenario to known-empty.
void init_load_scenario(TLoadScenario *load_scenario)
{
	static TLoadScenario constant_load_scenario = INIT_LOAD_SCENARIO;
	*load_scenario = constant_load_scenario;
}

// Free allocated memory for a load scenario and reset it to known-empty.
void clear_load_scenario(TLoadScenario *load_scenario)
{
	// Prescribed joint storage is static in non-contest versions.
	Safefree(load_scenario->prescribed_joints);
	init_load_scenario(load_scenario);
}

#define UNSIGNED_FROM_CHAR(C)	((C) - '0')
#define UNSIGNED_FROM_2_CHARS(P) (10 * UNSIGNED_FROM_CHAR((P)[0]) + UNSIGNED_FROM_CHAR((P)[1]))

// Fill contents of load scenario given a scenario index.  
// For V3 and V4, this amounts to looking the load scenario up in a table.
// For V4 (contest), we compute the load scenario from the index digits!
void setup_load_scenario(TLoadScenario *load_scenario, TScenarioDescriptor *desc)
{
	TJoint *prescribed_joints;
	unsigned n_prescribed_joints,
		panel_size,
		x, y,
		joint_index;

	clear_load_scenario(load_scenario);

	// Check that scenario index isn't null.
	if (desc->index < 0) {
		load_scenario->error = LoadScenarioIndexRange;
		return;
	}

	load_scenario->support_type = 0;

	// digit 10 => (0 = low pier, 1 = high pier)
	if (desc->id[9] > '0')
		load_scenario->support_type |= HI_NOT_LO;

	// digit 9 => panel point at which pier is located. (0 = no pier).
	load_scenario->intermediate_support_joint_no = UNSIGNED_FROM_CHAR(desc->id[8]);
	if (load_scenario->intermediate_support_joint_no > 0)
		load_scenario->support_type |= INTERMEDIATE_SUPPORT;

	// digit 8 => (0 = simple, 1 = arch, 2 = cable left, 3 = cable both)
	switch (desc->id[7]) {
	case '0':
		break;
	case '1':
		load_scenario->support_type |= ARCH_SUPPORT;
		break;
	case '2':
		load_scenario->support_type |= CABLE_SUPPORT_LEFT;
		break;
	case '3':
		load_scenario->support_type |= (CABLE_SUPPORT_LEFT | CABLE_SUPPORT_RIGHT);
		break;
	default:
		assert(0);
		break;
	}

	// digits 6 and 7 => meters under span
	load_scenario->under_meters = UNSIGNED_FROM_2_CHARS(&desc->id[5]);

	// digits 4 and 5 => meters over span
	load_scenario->over_meters =  UNSIGNED_FROM_2_CHARS(&desc->id[3]);

	// digits 2 and 3 => number of bridge panels
	load_scenario->n_panels = UNSIGNED_FROM_2_CHARS(&desc->id[1]);

	// digit 1 is the load case, 1-based
	load_scenario->load_case = UNSIGNED_FROM_CHAR(desc->id[0]) - 1;  // -1 correction for 0-based load_case table
	
	// There is no scaling of image in the 2004 version either, but geometry sizes changed.
	load_scenario->grid_size = 0.25;
	panel_size = 16;
	load_scenario->over_grids = load_scenario->over_meters * 4;
	load_scenario->under_grids = load_scenario->under_meters * 4;

	// load_scenario->joint_radius = ??;  Not set because Steve didn't give it to me. Not needed anyway.
	load_scenario->num_length_grids = load_scenario->n_panels * panel_size;
	load_scenario->n_loaded_joints = load_scenario->n_panels + 1;

	// Loaded joints are prescribed.
	n_prescribed_joints = load_scenario->n_loaded_joints;

	// Add one prescribed joint for the intermediate support, if any.
	if ( (load_scenario->support_type & INTERMEDIATE_SUPPORT) 
			&& !(load_scenario->support_type & HI_NOT_LO))
		n_prescribed_joints++;

	// Another two for the arch base, if we have an arch.
	if (load_scenario->support_type & ARCH_SUPPORT)
		n_prescribed_joints += 2;

	// And another one or two for cable anchorages if they're present.
	if (load_scenario->support_type & CABLE_SUPPORT_LEFT) 
		n_prescribed_joints++;
	if (load_scenario->support_type & CABLE_SUPPORT_RIGHT) 
		n_prescribed_joints++;

	// Allocate and fill prescribed joint vector.
	Newz(92, prescribed_joints, n_prescribed_joints, TJoint); 
	x = y = 0;
	for (joint_index = 0; joint_index < load_scenario->n_loaded_joints; joint_index++) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = x;
		prescribed_joints[joint_index].y = y;
		x += panel_size;
	}

	// Loop leaves joint_index pointing at next joint.  Add the low intermediate support, if any.
	if ( (load_scenario->support_type & INTERMEDIATE_SUPPORT) 
			&& !(load_scenario->support_type & HI_NOT_LO) ) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = (load_scenario->intermediate_support_joint_no - 1) * panel_size;
		prescribed_joints[joint_index].y = -(TCoordinate)load_scenario->under_grids;
		joint_index++;
	}

	// Add the arch base supports, if any.
	if (load_scenario->support_type & ARCH_SUPPORT) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = 0;
		prescribed_joints[joint_index].y = -(TCoordinate)load_scenario->under_grids;
		joint_index++;
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = prescribed_joints[load_scenario->n_loaded_joints - 1].x;
		prescribed_joints[joint_index].y = -(TCoordinate)load_scenario->under_grids;
		joint_index++;
	}

	// Add the cable anchorages, if any.
	if (load_scenario->support_type & CABLE_SUPPORT_LEFT) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = -CABLE_ANCHORAGE_X_OFFSET;
		prescribed_joints[joint_index].y = 0;
		joint_index++;
	}
	if (load_scenario->support_type & CABLE_SUPPORT_RIGHT) {
		prescribed_joints[joint_index].number = joint_index + 1;
		prescribed_joints[joint_index].x = prescribed_joints[load_scenario->n_loaded_joints - 1].x + CABLE_ANCHORAGE_X_OFFSET;
		prescribed_joints[joint_index].y = 0;
		joint_index++;
	}

	assert(joint_index == n_prescribed_joints);
	load_scenario->n_prescribed_joints = n_prescribed_joints;
	load_scenario->prescribed_joints = prescribed_joints;
}

void copy_load_scenario(TLoadScenario *dst, TLoadScenario *src)
{
	if (src->error != LoadScenarioNoError)
		return;
	clear_load_scenario(dst);
	*dst = *src;

	// Need fresh storage for prescribed joints.
	Newz(93, dst->prescribed_joints, dst->n_prescribed_joints, TJoint);
	memcpy(dst->prescribed_joints, src->prescribed_joints, dst->n_prescribed_joints * sizeof(TJoint));
}

int test_scenario_table(void)
{
	unsigned i, n;
	char invalid_scenario_ids[][SCENARIO_ID_SIZE + 1] = { 
		"----------",
		"0000000500",
		"1000000000",
		"3999999999",
	};
	TScenarioDescriptor desc[1];
	TLoadScenario load_scenario[1];

	init_load_scenario(load_scenario);

	// Check lookup function for bridges.
	printf("scenario lookup check (find good indices): ");
	for (i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl); i++) {
		printf("%d ", i);
		if (lookup_scenario_descriptor(desc, scenario_descriptor_tbl[i].id) < 0) {
			printf("\nfailed to find scenario id %s (position %d)\n", 
				scenario_descriptor_tbl[i].id, i);
			return 1;
		}
		setup_load_scenario(load_scenario, desc);
		if (load_scenario->error != LoadScenarioNoError) {
			printf("\nfailed to initialize load scenario for id %s (position %d)\n", 
				scenario_descriptor_tbl[i].id, i);
			return 1;
		}
		clear_load_scenario(load_scenario);
	}

	printf("ok\nscenario lookup check (reject bad indices): ");
	for (i = 0; i < STATIC_ARRAY_SIZE(invalid_scenario_ids); i++) {
		printf("%d ", i);
		if (lookup_scenario_descriptor(NULL, invalid_scenario_ids[i]) >= 0) {
			printf("\nfound invalid code %s (position %d)\n", invalid_scenario_ids[i], i);
			return 2;
		}
	}
	printf("ok\ncable anchorage scenarios: ");
	for (n = i = 0; i < STATIC_ARRAY_SIZE(scenario_descriptor_tbl); i++) {
		if (scenario_descriptor_tbl[i].id[7] > '1') {
			printf(" (%s) %s\n", scenario_descriptor_tbl[i].number, scenario_descriptor_tbl[i].id);
			n++;
		}
	}
	printf("%d cases ok\n", n);
	return 0;
}
