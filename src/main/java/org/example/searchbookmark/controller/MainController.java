package org.example.searchbookmark.controller;

import org.example.searchbookmark.model.vo.KeywordSearch;
import org.example.searchbookmark.service.SearchService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
//@RequestMapping("/") // 이런 경우는 생략해도 무방함
public class MainController {
    // 멤버변수
    private final SearchService searchService;
    // 구별을 굳이 안해도 돼 -> 1:1 대응이 되니까

    // 생성자 주입 -> 의존성 주입을 한 타입은? SearchService
    public MainController(SearchService searchService) {
        this.searchService = searchService;
    }

    @GetMapping
    public String index(Model model) throws Exception {
        List<KeywordSearch> result = searchService.searchByKeyword("4월은 너의 거짓말");
        model.addAttribute("result", result);
        return "index";
    }
}