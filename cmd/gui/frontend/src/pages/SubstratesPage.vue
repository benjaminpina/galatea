<script setup lang="ts">
import MainToolbar from '../components/MainToolbar.vue'
import SubstratesMenu from '../components/SubstratesMenu.vue'
</script>

<template>
    <div class="common-layout">
      <el-container>
        <el-header><MainToolbar /></el-header>
        <el-container>
          <el-aside width="200px"><SubstratesMenu /></el-aside>
          <el-container>
            <el-main>Substrates</el-main>
            <el-footer>Footer</el-footer>
          </el-container>
        </el-container>
      </el-container>
    </div>
  </template>