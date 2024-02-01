    parameter INT_NUMBER_OF_TAPS = 25;
    parameter INT_COEF_WIDTH = 15;
    logic signed[INT_COEF_WIDTH-1:0] fir_coefficients [INT_NUMBER_OF_TAPS-1:0] = '{
        INT_COEF_WIDTH'($rtoi((0.0012437503563049353) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.0026255113992609555) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-2.202047693231708**(-18)) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.007202182355254403) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.007229298946022438) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.01121889222439017) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.027167809725285923) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-1.0247064136175715**(-17)) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.05810892635686156) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.053808938774300624) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.08753250888649769) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.2971330913115606) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.3988555650582775) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.2971330913115606) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.08753250888649769) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.053808938774300624) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.05810892635686158) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-1.024706413617572**(-17)) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.027167809725285923) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.011218892224390178) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.0072292989460224465) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-0.007202182355254403) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((-2.202047693231709**(-18)) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.0026255113992609573) * (2.0**(INT_COEF_WIDTH)/2 - 1.0))),
        INT_COEF_WIDTH'($rtoi((0.0012437503563049353) * (2.0**(INT_COEF_WIDTH)/2 - 1.0)))
    };