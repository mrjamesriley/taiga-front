###
# Copyright (C) 2014-2015 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014-2015 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2015 David Barragán Merino <bameda@dbarragan.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/taskboard/lightboxes.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

CreateEditTaskDirective = ($repo, $model, $rs, $rootscope, $loading, lightboxService, $translate) ->
    link = ($scope, $el, attrs) ->
        $scope.isNew = true

        $scope.$on "taskform:new", (ctx, sprintId, usId) ->
            $scope.task = {
                project: $scope.projectId
                milestone: sprintId
                user_story: usId
                is_archived: false
                status: $scope.project.default_task_status
                assigned_to: null
                tags: []
            }
            $scope.isNew = true

            # Update texts for creation
            create = $translate.instant("COMMON.CREATE")
            $el.find(".button-green").html(create)

            newTask = $translate.instant("LIGHTBOX.CREATE_EDIT_TASK.TITLE")
            $el.find(".title").html(newTask + "  ")

            $el.find(".tag-input").val("")
            lightboxService.open($el)

        $scope.$on "taskform:edit", (ctx, task) ->
            $scope.task = task
            $scope.isNew = false

            # Update texts for edition
            save = $translate.instant("COMMON.SAVE")
            edit = $translate.instant("LIGHTBOX.CREATE_EDIT_TASK.ACTION_EDIT")

            $el.find(".button-green").html(save)
            $el.find(".title").html(edit + "  ")

            $el.find(".tag-input").val("")
            lightboxService.open($el)


        submitButton = $el.find(".submit-button")

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            if $scope.isNew
                promise = $repo.create("tasks", $scope.task)
                broadcastEvent = "taskform:new:success"
            else
                promise = $repo.save($scope.task)
                broadcastEvent = "taskform:edit:success"

            currentLoading = $loading()
                .target(submitButton)
                .start()

            # FIXME: error handling?
            promise.then (data) ->
                currentLoading.finish()
                lightboxService.close($el)
                $rootscope.$broadcast(broadcastEvent, data)

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


CreateBulkTasksDirective = ($repo, $rs, $rootscope, $loading, lightboxService) ->
    link = ($scope, $el, attrs) ->
        $scope.form = {data: "", usId: null}

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            data = $scope.form.data
            projectId = $scope.projectId
            sprintId = $scope.form.sprintId
            usId = $scope.form.usId

            promise = $rs.tasks.bulkCreate(projectId, sprintId, usId, data)
            promise.then (result) ->
                currentLoading.finish()
                $rootscope.$broadcast("taskform:bulk:success", result)
                lightboxService.close($el)

            # TODO: error handling
            promise.then null, ->
                currentLoading.finish()
                console.log "FAIL"

        $scope.$on "taskform:bulk", (ctx, sprintId, usId)->
            lightboxService.open($el)
            $scope.form = {data: "", sprintId: sprintId, usId: usId}

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module = angular.module("taigaTaskboard")

module.directive("tgLbCreateEditTask", [
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    "$tgLoading",
    "lightboxService",
    "$translate"
    CreateEditTaskDirective
])

module.directive("tgLbCreateBulkTasks", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "$tgLoading",
    "lightboxService",
    CreateBulkTasksDirective
])
