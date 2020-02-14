new Vue({
    el: '#redeliste',
    data() { return {
        role: null,
        session: null,
        nextSpeakerIds: [],
        listOpen: false,
        personId: null,
        wsConnected: false,
        wsURL: null,
    }},
    computed: {
        persons() {
            return [...this.session.persons].sort((a, b) => {
                let an = a.name.toUpperCase();
                let bn = b.name.toUpperCase();
                return an < bn ? -1 : an == bn ? 0 : 1;
            });
        },
        nextSpeakers() {
            return this.nextSpeakerIds.map(id => this.session.persons[id]);
        },
        isOnSpeakersList() {
            return this.nextSpeakerIds.includes(this.personId);
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
                let data            = JSON.parse(msg.data);
                this.session        = data.session;
                this.nextSpeakerIds = data.nextSpeakers;
                this.listOpen       = data.listOpen;
            };
            this.socket.onclose = () => {
                window.location.replace('/bye');
            };
        },
        disconnect(confirmText) {
            if (confirm(confirmText)) {
                this.socket.close();
                this.wsConnected = false;
                this.session     = null;
                window.location.replace('/bye');
            }
        },
        requestSpeak() {
            this.socket.send('RQSP');
        },
        revoke() {
            this.socket.send('REVK');
        },
        callSpeaker() {
            this.socket.send('NEXT');
        },
        overrideSpeaker(id) {
            this.socket.send('NEXT ' + id);
        },
        closeList() {
            this.socket.send('CLOSELIST');
        },
        openList() {
            this.socket.send('OPENLIST');
        },
        clearItem(confirmText) {
            if (confirm(confirmText)) {
                this.socket.send('NEXTITEM');
            }
        },
        closeSession(confirmText) {
            if (confirm(confirmText)) {
                this.socket.send('CLOSESESSION');
            }
        },
    },
    beforeMount() {
        this.role = this.$el.attributes['data-role'].value;
    },
    mounted() {
        axios.get('/data.json').then(res => {
            this.session    = res.data.session;
            this.personId   = res.data.personId;
            this.wsURL      = res.data.wsURL;
            this.connect();
        });
    },
})
