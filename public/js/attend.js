new Vue({
    el: '#attend',
    data() { return {
        session: null,
        userId: null,
        wsConnected: false,
        wsURL: null,
    }},
    methods: {
        connect() {
            if (! this.wsURL) return;
            this.socket = new WebSocket(this.wsURL);
            this.socket.onopen = () => {
                this.wsConnected = true;
                console.log('Connected...');
                this.socket.onmessage = e => console.log(e);
            };
        },
        disconnect() {
            this.socket.close();
            this.wsConnected = false;
            console.log('Disconnected');
        },
        sync() {
            this.socket.send('foo');
        }
    },
    mounted() {
        axios.get('/data.json').then(res => {
            this.session = res.data.session;
            this.userId  = res.data.userId;
            this.wsURL   = res.data.wsURL;
        });
    }
})
