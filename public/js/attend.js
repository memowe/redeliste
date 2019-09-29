new Vue({
    el: '#attend',
    data() { return {
        session: null,
        userId: null
    }},
    mounted() {
        axios.get('/data.json').then(res => {
            this.session = res.data.session;
            this.userId  = res.data.userId;
        });
    }
})
