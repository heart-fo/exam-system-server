package com.exam.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.exam.common.Result;
import com.exam.entity.Banner;
import com.exam.service.BannerService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.var;

@RestController
@RequestMapping("/api/my-banners")
@CrossOrigin
@Tag(name = "我的轮播图", description = "我的轮播图相关操作")
public class MyBannerController {

    @Autowired
    private BannerService bannerService;

    @GetMapping("/list")
    @Operation(summary = "获取我的轮播图列表", description = "获取我的轮播图列表")
    public Result<List<Banner>> getMyBanners() {
        var wrapper = new LambdaQueryWrapper<Banner>().orderByAsc(Banner::getSortOrder);
        return Result.success(bannerService.list(wrapper));
    }
    @GetMapping("/active")
    @Operation(summary = "获取启用的轮播图列表", description = "获取所有启用（激活）状态的轮播图")
    public Result<List<Banner>> getActiveBanners() {
        return Result.success(bannerService.list(new LambdaQueryWrapper<Banner>().eq(Banner::getIsActive, true).orderByAsc(Banner::getSortOrder)));
    }
    @GetMapping("/toggle")
    @Operation(summary = "切换轮播图启用状态", description = "根据ID切换轮播图的启用（激活）状态")
    public Result<Boolean> toggleBannerStatus(Long id) {
        if (id == null) {
            return Result.error("轮播图ID不能为空");
        }
        Banner banner = bannerService.getById(id);
        if (banner == null) {
            return Result.error("轮播图不存在");
        }
        banner.setIsActive(!Boolean.TRUE.equals(banner.getIsActive()));
        boolean updated = bannerService.updateById(banner);
        return updated ? Result.success(banner.getIsActive()) : Result.error("轮播图状态切换失败");
    }
    @GetMapping("/delete")
    @Operation(summary = "删除轮播图", description = "根据ID删除轮播图")
    public Result<Boolean> deleteBanner(Long id) {
        if (id == null) {
            return Result.error("轮播图ID不能为空");
        }
        boolean removed = bannerService.removeById(id);
        return removed ? Result.success(true) : Result.error("轮播图删除失败");
    }

    @GetMapping("/detail/{id}")
    @Operation(summary = "获取轮播图详情", description = "根据ID获取轮播图详细信息")
    public Result<Banner> getBannerDetail(@PathVariable("id") Long id) {
        if (id == null) {
            return Result.error("轮播图ID不能为空");
        }
        Banner banner = bannerService.getById(id);
        if (banner == null) {
            return Result.error("轮播图不存在");
        }
        return Result.success(banner);
    }
}
