<template>
  <div id="app">
    <section class="section">
      <div class="container">
        <Query @search="searchQuery" />
      </div>

      <div class="container mt-4" v-if="retrievedResults.length > 0">
        <div class="box">
          Suggested discount: <strong>{{ median(retrievedResults.map(x => x.discount)) }}</strong>
          <br>
          <small>Computed as median of applied discounts</small>
        </div>
      </div>

      <div class="container mt-4">
        <b-table
          :data="retrievedResults"
          :columns="columns"
          v-if="retrievedResults.length > 0"
        />
        <b-loading is-full-page v-model="isSearching"></b-loading>
      </div>
    </section>
  </div>
</template>

<script>
import Query from "./components/Query.vue";

export default {
  name: "App",
  components: {
    Query,
  },
  data() {
    return {
      retrievedResults: [],
      isSearching: false,
      columns: [
        {
          field: "description",
          label: "Description",
        },
        {
          field: "docSim",
          label: "Document similarity (max = 1)",
          numeric: true,
        },
        {
          field: "clientId",
          label: "Client #",
        },
        {
          field: "clientSim",
          label: "Client similarity (max = 1)",
          numeric: true,
        },
        {
          field: "discount",
          label: "Applied discount",
          numeric: true,
        },
      ],
    };
  },
  methods: {
    async searchQuery(params) {
      this.isSearching = true;
      const res = await this.$api.get("/query", {
        params: {
          text: params["querytext"],
          client: params["client"],
          num: params["num"],
        },
      });
      this.isSearching = false;
      this.retrievedResults = res.data;
    },

    median(values) {
      if (values.length === 0) throw new Error("No inputs");

      values.sort(function (a, b) {
        return a - b;
      });

      var half = Math.floor(values.length / 2);

      if (values.length % 2) return values[half];

      return (values[half - 1] + values[half]) / 2.0;
    }
  }
};
</script>

<style>
</style>
