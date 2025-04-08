<script setup lang="ts">
import { substrate } from '../../wailsjs/go/models'
import MainToolbar from '../components/MainToolbar.vue'
import SubstratesMenu from '../components/SubstratesMenu.vue'
import useSubstrates from '../services/substrates/useSubstrates'

const { substratesQuery } = useSubstrates()
const { data } = substratesQuery


</script>

<template>
    <div class="common-layout">
      <el-container>
        <el-header><MainToolbar /></el-header>
        <el-container>
          <el-aside width="200px"><SubstratesMenu /></el-aside>
          <el-container>
            <el-main>Substrates</el-main>
            <ul v-if="data?.data">
              <li v-for="substrate in data?.data" :key="substrate.id">
                {{ substrate.name }} <el-badge :value="substrate.color" :color="substrate.color" />
              </li>
            </ul>
            <el-footer>Footer</el-footer>
          </el-container>
        </el-container>
      </el-container>
    </div>
  </template>