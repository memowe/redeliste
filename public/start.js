new Vue({
    el: '#form',
    data() { return {
        name: '',
        pname: '',
    }},
    computed: {
        empty() {
            return this.name == '' || this.pname == '';
        }
    },
});
