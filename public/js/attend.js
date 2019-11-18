new Vue({
    el: '#attend',
    data() { return {
        session: null,
        nextSpeakerIds: [],
        userId: null,
        wsConnected: false,
        wsURL: null,
    }},
    computed: {
        nextSpeakers() {
            return this.nextSpeakerIds.map(id => this.session.persons[id]);
        },
        isOnSpeakersList() {
            return this.nextSpeakerIds.includes(this.userId);
        },
    },
    methods: {
        connect() {
            if (! this.wsURL) return;
            this.socket = new WebSocket(this.wsURL);
            this.socket.onopen = () => {
                this.wsConnected = true;
            };
            this.socket.onmessage = msg => {
                let data = JSON.parse(msg.data);
                this.session = data.session;
                this.nextSpeakerIds = data.nextSpeakers;
            };
        },
        disconnect() {
            this.socket.close();
            this.wsConnected = false;
            this.session     = null;
        },
        requestSpeak() {
            this.socket.send('RQSP');
        }
    },
    mounted() {
        axios.get('/data.json').then(res => {
            this.session = res.data.session;
            this.userId  = res.data.userId;
            this.wsURL   = res.data.wsURL;
            this.connect();
        });
    }
})
