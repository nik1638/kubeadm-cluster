resource "aws_instance" "master" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k8s.id]

  user_data = file("${path.module}/scripts/master_user_data.sh")

  # provisioner "file" {
  #   source      = "scripts/common.sh"
  #   destination = "/tmp/common.sh"
  # }

  # provisioner "file" {
  #   source      = "scripts/master.sh"
  #   destination = "/tmp/master.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/common.sh /tmp/master.sh",
  #     "sudo /tmp/common.sh",
  #     "sudo /tmp/master.sh"
  #   ]
  # }

  # connection {
  #   type        = "ssh"
  #   user        = "ubuntu"
  #   private_key = file(var.ssh_private_key_path)
  #   host        = self.public_ip
  # }

  tags = {
    Name = "k8s-master"
  }
}



# resource "null_resource" "get_join_command" {
#   depends_on = [aws_instance.master]

#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = aws_instance.master.public_ip
#       private_key = file(var.ssh_private_key_path)
#     }

#     inline = [
#       # Wait until kubeadm is available
#       "until command -v kubeadm >/dev/null 2>&1; do sleep 10; done",

#       # Wait until API server is ready
#       "until sudo kubectl get nodes >/dev/null 2>&1; do sleep 10; done",

#       # Create join command
#       "sudo /usr/bin/kubeadm token create --print-join-command | sudo tee /tmp/kube_join.sh"
#     ]
#   }

#   triggers = {
#     always_run = timestamp()
#   }
# }



# resource "local_file" "join_cmd" {
#   depends_on = [null_resource.get_join_command]

#   content  = chomp(
#     trimspace(
#       replace(
#         chomp(
#           join("", [
#             for line in split("\n", chomp(
#               chomp(
#                 chomp("")
#               )
#             )) : line
#           ])
#         ),
#         "\r", ""
#       )
#     )
#   )

#   filename = "${path.module}/join-command.txt"
# }

# Generate join script on master
resource "null_resource" "generate_join" {
  depends_on = [aws_instance.master]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.master.public_ip
      private_key = file(var.ssh_private_key_path)
    }

inline = [
  "set -e",
  "sudo kubeadm token create --print-join-command | sudo tee /tmp/join.sh",
  "sudo chmod +x /tmp/join.sh",
  "ls -l /tmp/join.sh",
  "cat /tmp/join.sh"
  ]
  }
}

# Run join script on each worker
# resource "null_resource" "join_workers" {
#   for_each = { for idx, inst in aws_instance.worker : idx => inst }

#   depends_on = [
#     null_resource.generate_join
#   ]

#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = each.value.public_ip
#       private_key = file(var.ssh_private_key_path)
#     }

# #     inline = [
# #   "set -e",

# #   "scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip}:/tmp/join.sh /tmp/join.sh",

# #   "ls -l /tmp/join.sh",

# #   "sudo bash /tmp/join.sh"
# # ]
# inline = [
#   "set -e",
#   "scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} ubuntu@${aws_instance.master.public_ip}:/tmp/join.sh /tmp/join.sh",
#   "ls -l /tmp/join.sh",
#   "sudo bash /tmp/join.sh"
# ]


#   }
# }
# resource "null_resource" "join_workers" {
#   for_each = { for idx, inst in aws_instance.worker : idx => inst }

#   depends_on = [null_resource.generate_join]

#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = aws_instance.master.public_ip
#       private_key = file(var.ssh_private_key_path)
#     }

#     inline = [
#       "set -e",
#       "sudo kubeadm token create --print-join-command | sudo tee /tmp/join.sh",
#       "ssh -o StrictHostKeyChecking=no ubuntu@${each.value.private_ip} 'sudo bash -s' < /tmp/join.sh"
#     ]
#   }
# }

resource "null_resource" "join_workers" {
  for_each = { for idx, inst in aws_instance.worker : idx => inst }

  depends_on = [null_resource.generate_join]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = each.value.public_ip
      private_key = file(var.ssh_private_key_path)
    }

    inline = [
      "set -e",

      # Fetch join command from master
      "JOIN_CMD=$(ssh -o StrictHostKeyChecking=no ubuntu@${aws_instance.master.public_ip} 'sudo kubeadm token create --print-join-command')",

      # Run join
      "sudo $JOIN_CMD"
    ]
  }
}


