<template>
  <section class="hero">
    <div class="hero-body">
      <div class="container">
        <b-field label="Service description">
          <b-input icon="note-text-outline" v-model="querytext" placeholder="book shelf"></b-input>
        </b-field>

        <b-field label="Clients">
          <b-autocomplete
            placeholder="Craig Reiter"
            v-model="searchedClient"
            :data="filteredClient"
            icon="account-circle-outline"
            clearable
            @select="selectClient"
          >
            <template #empty>No results found</template>
            <template slot-scope="props">
              <div class="media-content">
                <p class="title is-6">{{ props.option.name }}</p>
                <p class="subtitle is-6">
                  <b-icon icon="map-marker" size="is-small"> </b-icon>
                  {{ props.option.city }}
                </p>
              </div>
            </template>
          </b-autocomplete>
        </b-field>

        <b-field label="Number of results">
          <b-numberinput v-model="num"></b-numberinput>
        </b-field>

        <b-button icon-left="magnify" type="is-primary" expanded @click="search"
          >Search</b-button
        >
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: "Query",
  props: ["value"],
  data() {
    return {
      querytext: "",
      clients: [],
      searchedClient: "",
      client: null,
      num: 5,
    };
  },

  methods: {
    selectClient(c) {
      this.client = c;
      this.searchedClient = this.client.name;
    },

    search() {
      this.$emit("search", {
        querytext: this.querytext,
        client: this.client.id,
        num: this.num
      });
    },
  },

  async mounted() {
    const res = await this.$api.get("/clients");
    this.clients = res.data;
  },

  computed: {
    filteredClient() {
      let filtered = [];
      let toMatch = this.searchedClient.toLowerCase();

      if (this.searchedClient !== undefined) {
        filtered = this.clients.filter(
          (option) => option.name.toLowerCase().startsWith(toMatch)
        );
        filtered = filtered.slice(1, 100);
      }

      return filtered;
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
