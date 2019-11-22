new Vue({
    el: '#form',
    data() { return {
        token: '',
        name: '',
    }},
    computed: {
        empty() {
            return this.token == '' || this.name == '';
        }
    },
});
