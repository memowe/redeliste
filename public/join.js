new Vue({
    el: '#form',
    data() { return {
        token: '',
        name: '',
        sex: 'female',
    }},
    computed: {
        empty() {
            return this.token == '' || this.name == '';
        }
    },
    methods: {
        submit(event) {
            event.preventDefault();

            // Prepare form submission
            let data = new FormData();
            data.append('name', this.name);
            data.append('sex', this.sex);

            // Request session joinal
            axios.post('/session/' + this.token + '/person', data).then(res => {

                // Store join result data
                sessionStorage.setItem('token', this.token);
                sessionStorage.setItem('isAdmin', false);
                sessionStorage.setItem('personId', res.data.personId);

                // Go to next screen
                window.location.replace('/redeliste.html');

            }).catch(error => {
                console.log(error)
                if (error.response && error.response.status == 404) {
                    alert('Unbekannter Code!');
                }
            });
        }
    },
});
