
    function DISP() {
        fetch('https://' + GetParentResourceName() + '/cad_disp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        });
    }
    function ENR() {
        fetch('https://' + GetParentResourceName() + '/cad_enr', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        });
    }
    function CLR() {
        fetch('https://' + GetParentResourceName() + '/cad_clr', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        });
    }
    function VEHS() {
        fetch('https://' + GetParentResourceName() + '/cad_vehs', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        });
    }
    function MISC() {
        fetch('https://' + GetParentResourceName() + '/cad_misc', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        });
    }
    function FREE() {
        fetch('https://' + GetParentResourceName() + '/cad_free', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({}),
        });
    }
