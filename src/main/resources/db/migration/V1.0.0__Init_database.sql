CREATE DATABASE IF NOT EXISTS exam_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE exam_system;

-- 创建用户表
CREATE TABLE IF NOT EXISTS `users` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username` varchar(50) NOT NULL COMMENT '用户名',
    `password` varchar(100) NOT NULL COMMENT '密码',
    `real_name` varchar(50) COMMENT '真实姓名',
    `role` varchar(20) NOT NULL DEFAULT 'user' COMMENT '角色：admin、user',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 创建分类表
CREATE TABLE IF NOT EXISTS `categories` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `name` varchar(50) NOT NULL COMMENT '分类名称',
    `parent_id` bigint NOT NULL DEFAULT '0' COMMENT '父分类ID',
    `sort` int NOT NULL DEFAULT '0' COMMENT '排序',
    PRIMARY KEY (`id`),
    KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目分类表';

-- 创建题目表
CREATE TABLE IF NOT EXISTS `questions` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '题目ID',
    `title` text NOT NULL COMMENT '题目标题',
    `type` varchar(20) NOT NULL COMMENT '题目类型：CHOICE(选择题)、JUDGE(判断题)、TEXT(简答题)',
    `category_id` bigint NOT NULL COMMENT '分类ID',
    `difficulty` varchar(10) NOT NULL COMMENT '难度：EASY、MEDIUM、HARD',
    `score` int NOT NULL DEFAULT 5 COMMENT '分值',
    `analysis` text COMMENT '题目解析',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category_id`),
    KEY `idx_type` (`type`),
    CONSTRAINT `fk_question_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目表';

-- 创建选择题选项表
CREATE TABLE IF NOT EXISTS `question_choices` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '选项ID',
    `question_id` bigint NOT NULL COMMENT '题目ID',
    `content` text NOT NULL COMMENT '选项内容',
    `is_correct` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否正确答案',
    `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
    PRIMARY KEY (`id`),
    KEY `idx_question` (`question_id`),
    CONSTRAINT `fk_choice_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='选择题选项表';

-- 创建题目答案表（用于判断题和简答题）
CREATE TABLE IF NOT EXISTS `question_answers` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '答案ID',
    `question_id` bigint NOT NULL COMMENT '题目ID',
    `answer` text NOT NULL COMMENT '答案内容',
    `keywords` text COMMENT '关键词（用于简答题评分）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_question` (`question_id`),
    CONSTRAINT `fk_answer_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='题目答案表';

-- 创建试卷表
CREATE TABLE IF NOT EXISTS `exams` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '试卷ID',
    `name` varchar(100) NOT NULL COMMENT '试卷名称',
    `description` text COMMENT '试卷描述',
    `duration` int NOT NULL COMMENT '考试时长（分钟）',
    `pass_score` int NOT NULL COMMENT '及格分数',
    `total_score` int NOT NULL COMMENT '总分',
    `question_count` int NOT NULL COMMENT '题目数量',
    `status` varchar(20) NOT NULL DEFAULT 'DRAFT' COMMENT '状态：DRAFT(草稿)、PUBLISHED(已发布)、CLOSED(已关闭)',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='试卷表';

-- 创建试卷题目关联表
CREATE TABLE IF NOT EXISTS `exam_questions` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
    `exam_id` bigint NOT NULL COMMENT '试卷ID',
    `question_id` bigint NOT NULL COMMENT '题目ID',
    `question_score` int NOT NULL COMMENT '题目分值',
    `question_order` int NOT NULL COMMENT '题目顺序',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_exam_question` (`exam_id`, `question_id`),
    KEY `idx_exam` (`exam_id`),
    KEY `idx_question` (`question_id`),
    CONSTRAINT `fk_exam_question_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_exam_question_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='试卷题目关联表';

-- 创建考试记录表
CREATE TABLE IF NOT EXISTS `exam_records` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    `exam_id` bigint NOT NULL COMMENT '试卷ID',
    `student_name` varchar(50) NOT NULL COMMENT '考生姓名',
    `student_number` varchar(50) NOT NULL COMMENT '考生学号/工号',
    `total_score` int NOT NULL DEFAULT 0 COMMENT '总得分',
    `answers` text COMMENT '答题记录（JSON格式）',
    `start_time` datetime NOT NULL COMMENT '开始时间',
    `end_time` datetime COMMENT '结束时间',
    `status` varchar(20) NOT NULL DEFAULT 'ONGOING' COMMENT '状态：ONGOING(进行中)、FINISHED(已完成)、TIMEOUT(已超时)',
    `submit_ip` varchar(50) COMMENT '提交IP',
    `window_switches` int DEFAULT 0 COMMENT '切屏次数',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_exam` (`exam_id`),
    KEY `idx_student` (`student_number`),
    KEY `idx_status` (`status`),
    CONSTRAINT `fk_record_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考试记录表';

-- 插入管理员用户
INSERT INTO `users` (`username`, `password`, `real_name`, `role`) VALUES
('admin', 'admin123', '管理员', 'admin');

-- 插入题型分类（一级分类）
INSERT INTO `categories` (`name`, `parent_id`, `sort`) VALUES
('选择题', 0, 1),      -- id = 1
('判断题', 0, 2),      -- id = 2
('简答题', 0, 3);      -- id = 3

-- 插入技术分类（二级分类）
INSERT INTO `categories` (`name`, `parent_id`, `sort`) VALUES
-- 选择题的子分类
('Java基础', 1, 1),        -- id = 4
('Java Web', 1, 2),        -- id = 5
('Spring全家桶', 1, 3),    -- id = 6
('数据库', 1, 4),          -- id = 7
('前端开发', 1, 5),        -- id = 8
('计算机网络', 1, 6),      -- id = 9
('操作系统', 1, 7),        -- id = 10
('设计模式', 1, 8),        -- id = 11

-- 判断题的子分类
('编程规范', 2, 1),        -- id = 12
('最佳实践', 2, 2),        -- id = 13
('架构设计', 2, 3),        -- id = 14
('性能优化', 2, 4),        -- id = 15

-- 简答题的子分类
('项目架构', 3, 1),        -- id = 16
('技术方案', 3, 2),        -- id = 17
('故障排查', 3, 3),        -- id = 18
('系统设计', 3, 4);        -- id = 19

-- 插入示例题目
-- 1. Java基础选择题
INSERT INTO `questions` (`title`, `type`, `category_id`, `difficulty`, `score`, `analysis`) VALUES
('以下哪个不是Java的基本数据类型？', 'CHOICE', 4, 'EASY', 5, 'Java中的基本数据类型有8种：byte、short、int、long、float、double、char和boolean。String是引用类型。');

SET @last_question_id = LAST_INSERT_ID();

INSERT INTO `question_choices` (`question_id`, `content`, `is_correct`, `sort`) VALUES
(@last_question_id, 'int', 0, 1),
(@last_question_id, 'boolean', 0, 2),
(@last_question_id, 'String', 1, 3),
(@last_question_id, 'double', 0, 4);

-- 2. Spring相关选择题
INSERT INTO `questions` (`title`, `type`, `category_id`, `difficulty`, `score`, `analysis`) VALUES
('Spring Boot的核心注解是？', 'CHOICE', 6, 'EASY', 5, '@SpringBootApplication是一个组合注解，包含@SpringBootConfiguration、@EnableAutoConfiguration和@ComponentScan。');

SET @last_question_id = LAST_INSERT_ID();

INSERT INTO `question_choices` (`question_id`, `content`, `is_correct`, `sort`) VALUES
(@last_question_id, '@SpringBootApplication', 1, 1),
(@last_question_id, '@Configuration', 0, 2),
(@last_question_id, '@EnableAutoConfiguration', 0, 3),
(@last_question_id, '@ComponentScan', 0, 4);

-- 3. 编程规范判断题
INSERT INTO `questions` (`title`, `type`, `category_id`, `difficulty`, `score`, `analysis`) VALUES
('在Java中，接口的所有方法默认都是public abstract的', 'JUDGE', 12, 'MEDIUM', 5, '在Java中，接口中未声明访问修饰符的方法默认都是public abstract的，这是Java语言的规范。');

SET @last_question_id = LAST_INSERT_ID();

INSERT INTO `question_answers` (`question_id`, `answer`) VALUES
(@last_question_id, 'TRUE');

-- 4. 项目架构简答题
INSERT INTO `questions` (`title`, `type`, `category_id`, `difficulty`, `score`, `analysis`) VALUES
('简述Spring IoC的概念和作用', 'TEXT', 16, 'MEDIUM', 10, 'IoC（控制反转）是Spring框架的核心概念，它将传统上由程序代码直接操控的对象的调用权交给容器，通过容器来实现对象组件的装配和管理。');

SET @last_question_id = LAST_INSERT_ID();

INSERT INTO `question_answers` (`question_id`, `answer`, `keywords`) VALUES
(@last_question_id, 'IoC（Inversion of Control，控制反转）是Spring框架的核心概念之一。它将传统上由程序代码直接操控的对象的调用权交给容器，通过容器来实现对象组件的装配和管理。这样做的好处是降低组件之间的耦合度，增加系统的可维护性和灵活性。', 'IoC,控制反转,容器,解耦,依赖注入');

-- 插入示例试卷
INSERT INTO `exams` (`name`, `description`, `duration`, `pass_score`, `total_score`, `question_count`, `status`) VALUES
('Java基础知识测试', '测试Java基础知识掌握情况，包含基础语法、面向对象等内容', 60, 60, 100, 4, 'PUBLISHED'),
('Spring框架开发测试', '测试Spring框架相关知识，包含Spring Boot、Spring MVC等内容', 90, 70, 100, 4, 'PUBLISHED');

-- 关联试卷和题目
INSERT INTO `exam_questions` (`exam_id`, `question_id`, `question_score`, `question_order`) VALUES
-- Java基础知识测试试卷
(1, 1, 25, 1),  -- Java基础选择题
(1, 2, 25, 2),  -- Spring选择题
(1, 3, 25, 3),  -- 编程规范判断题
(1, 4, 25, 4),  -- 项目架构简答题

-- Spring框架开发测试试卷
(2, 2, 30, 1),  -- Spring选择题
(2, 3, 20, 2),  -- 编程规范判断题
(2, 4, 30, 3),  -- 项目架构简答题
(2, 1, 20, 4);  -- Java基础选择题

-- 插入示例考试记录
INSERT INTO `exam_records` (`exam_id`, `student_name`, `student_number`, `total_score`, `answers`, `start_time`, `end_time`, `status`, `submit_ip`, `window_switches`) VALUES
(1, '张三', '2024001', 85, '{"1":"C","2":"A","3":"TRUE","4":"IoC是Spring框架的核心概念..."}', NOW(), DATE_ADD(NOW(), INTERVAL 30 MINUTE), 'FINISHED', '127.0.0.1', 0),
(1, '李四', '2024002', 75, '{"1":"C","2":"B","3":"TRUE","4":"IoC表示控制反转..."}', NOW(), DATE_ADD(NOW(), INTERVAL 45 MINUTE), 'FINISHED', '127.0.0.1', 2); 