new Vue({
    el: '#form',
    data() { return {
        name: '',
        pname: '',
        sex: 'female',
    }},
    computed: {
        empty() {
            return this.name == '' || this.pname == '';
        }
    },
    methods: {
        submit(event) {
            event.preventDefault();

            // Prepare form submission
            let data = new FormData();
            data.append('name', this.name);
            data.append('pname', this.pname);
            data.append('sex', this.sex);

            // Requestion session creation
            axios.post('/session', data).then(res => {

                // Store creation result data
                sessionStorage.setItem('token', res.data.token);
                sessionStorage.setItem('adminToken', res.data.adminToken);
                sessionStorage.setItem('isAdmin', true);
                sessionStorage.setItem('personId', res.data.personId);

                // Go to next screen
                window.location.replace('/redeliste.html');

            }).catch(error => console.log(error));
        }
    },
});
